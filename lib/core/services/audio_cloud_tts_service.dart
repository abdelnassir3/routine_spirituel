import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Cloud TTS contract: synthesize text to a cached audio file and return path
abstract class CloudTtsService {
  Future<String> synthesizeToCache(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.02,
  });
}

/// Google Cloud TTS implementation using API key
class GoogleCloudTtsService implements CloudTtsService {
  GoogleCloudTtsService(this._apiKey, {Dio? dio}) : _dio = dio ?? Dio();
  final String _apiKey;
  final Dio _dio;

  @override
  Future<String> synthesizeToCache(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.02,
  }) async {
    final dir = await _cacheDir();
    final key = _hashKey('gcloud', text, voice, speed, pitch);
    final out = p.join(dir.path, '$key.mp3');
    final f = File(out);
    if (await f.exists()) return f.path;

    final (languageCode, voiceName) = _parseVoice(voice);
    final url =
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey';

    final body = {
      'input': {'text': text},
      'voice': {
        'languageCode': languageCode,
        if (voiceName != null) 'name': voiceName,
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
        'speakingRate': speed.clamp(0.25, 4.0),
        'pitch': _pitchToSemitones(pitch),
      },
    };

    final resp = await _dio.post(url, data: body);
    final data = resp.data as Map;
    final b64 = (data['audioContent'] ?? '') as String;
    if (b64.isEmpty) {
      throw Exception('Cloud TTS: empty audio content');
    }
    final bytes = base64Decode(b64);
    await f.writeAsBytes(bytes);
    return f.path;
  }

  Future<Directory> _cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'tts-cache'));
    if (!(await dir.exists())) await dir.create(recursive: true);
    return dir;
  }

  String _hashKey(
      String provider, String text, String voice, double speed, double pitch) {
    final digest =
        sha1.convert(utf8.encode('$provider|$voice|$speed|$pitch|$text'));
    return digest.toString();
  }

  /// Accepts locale like 'fr-FR' or full name like 'fr-FR-Neural2-A'
  (String, String?) _parseVoice(String v) {
    final s = v.replaceAll('_', '-');
    if (RegExp(r'^[a-zA-Z]{2}(-[A-Za-z]{2})$').hasMatch(s)) {
      return (s, null);
    }
    final parts = s.split('-');
    if (parts.length >= 2) {
      final lang = '${parts[0]}-${parts[1]}';
      return (lang, s);
    }
    return (s, null);
  }

  /// Map pitch ratio (0.8–1.2) to semitones (-20..+20)
  double _pitchToSemitones(double ratio) {
    // semitones = 12 * log2(ratio)
    return (12.0 * (math.log(ratio) / math.log(2))).clamp(-20.0, 20.0);
  }
}

/// Amazon Polly with AWS Signature V4
class AwsPollyTtsService implements CloudTtsService {
  AwsPollyTtsService(
      {required this.accessKey,
      required this.secretKey,
      required this.region,
      Dio? dio})
      : _dio = dio ?? Dio();
  final String accessKey;
  final String secretKey;
  final String region; // e.g., 'eu-west-1'
  final Dio _dio;

  @override
  Future<String> synthesizeToCache(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.02,
  }) async {
    final dir = await _cacheDir();
    final key = _hashKey('polly', text, voice, speed, pitch);
    final out = p.join(dir.path, '$key.mp3');
    final f = File(out);
    if (await f.exists()) return f.path;

    final voiceId = _mapVoice(voice);
    const engine = 'neural';
    final url = 'https://polly.$region.amazonaws.com/v1/speech';
    final body = {
      'OutputFormat': 'mp3',
      'Text': text,
      'VoiceId': voiceId,
      'Engine': engine,
      // Optional tweaks could be applied with SSML; for now keep plain text
      // 'LanguageCode': _langCodeForVoice(voiceId),
    };
    final payload = jsonEncode(body);

    final headers = _sigV4Headers(
      method: 'POST',
      service: 'polly',
      host: 'polly.$region.amazonaws.com',
      region: region,
      path: '/v1/speech',
      query: '',
      payload: payload,
    );

    final resp = await _dio.post(
      url,
      data: payload,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
      ),
    );
    final bytes = resp.data as List<int>;
    await f.writeAsBytes(bytes);
    return f.path;
  }

  Map<String, String> _sigV4Headers({
    required String method,
    required String service,
    required String host,
    required String region,
    required String path,
    required String query,
    required String payload,
  }) {
    final t = DateTime.now().toUtc();
    final amzDate = _fmtAmz(t);
    final dateStamp = _fmtDate(t);
    const algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = '$dateStamp/$region/$service/aws4_request';
    final canonicalUri = path;
    final canonicalQueryString = query;
    final canonicalHeaders = 'content-type:application/json\n'
        'host:$host\n'
        'x-amz-date:$amzDate\n';
    const signedHeaders = 'content-type;host;x-amz-date';
    final payloadHash = sha256.convert(utf8.encode(payload)).toString();
    final canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final stringToSign = [
      algorithm,
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    List<int> hmac(List<int> key, String data) =>
        Hmac(sha256, key).convert(utf8.encode(data)).bytes;
    final kDate = hmac(utf8.encode('AWS4$secretKey'), dateStamp);
    final kRegion = hmac(kDate, region);
    final kService = hmac(kRegion, service);
    final kSigning = hmac(kService, 'aws4_request');
    final signature =
        Hmac(sha256, kSigning).convert(utf8.encode(stringToSign)).toString();

    final authorization =
        '$algorithm Credential=$accessKey/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';
    return {
      'x-amz-date': amzDate,
      'Authorization': authorization,
      'Host': host,
    };
  }

  String _fmtAmz(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}T${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}${t.second.toString().padLeft(2, '0')}Z';
  String _fmtDate(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}';

  String _mapVoice(String v) {
    final trimmed = v.trim();
    // If user provided a Polly VoiceId (e.g., 'Lea', 'Hala'), use it directly
    if (!trimmed.contains('-') && trimmed.isNotEmpty) return trimmed;
    final low = trimmed.toLowerCase();
    if (low.startsWith('ar')) return 'Hala'; // ar-SA neural default
    return 'Lea'; // fr-FR neural default
  }

  Future<Directory> _cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'tts-cache'));
    if (!(await dir.exists())) await dir.create(recursive: true);
    return dir;
  }

  String _hashKey(
      String provider, String text, String voice, double speed, double pitch) {
    final digest =
        sha1.convert(utf8.encode('$provider|$voice|$speed|$pitch|$text'));
    return digest.toString();
  }
}

/// Azure TTS implementation using subscription key and region endpoint
class AzureCloudTtsService implements CloudTtsService {
  AzureCloudTtsService(this._apiKey, this._region, {Dio? dio})
      : _dio = dio ?? Dio();
  final String _apiKey;
  final String _region; // e.g., 'francecentral'
  final Dio _dio;

  @override
  Future<String> synthesizeToCache(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.02,
  }) async {
    final dir = await _cacheDir();
    final key = _hashKey('azure', text, voice, speed, pitch);
    final out = p.join(dir.path, '$key.mp3');
    final f = File(out);
    if (await f.exists()) return f.path;

    final voiceName = _azureVoiceName(voice);
    final url =
        'https://$_region.tts.speech.microsoft.com/cognitiveservices/v1';
    final ssml =
        _buildSsml(text, voiceName: voiceName, speed: speed, pitch: pitch);
    final resp = await _dio.post(
      url,
      data: ssml,
      options: Options(
        headers: {
          'Ocp-Apim-Subscription-Key': _apiKey,
          'Content-Type': 'application/ssml+xml',
          'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
        },
        responseType: ResponseType.bytes,
      ),
    );
    final bytes = resp.data as List<int>;
    await f.writeAsBytes(bytes);
    return f.path;
  }

  Future<Directory> _cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'tts-cache'));
    if (!(await dir.exists())) await dir.create(recursive: true);
    return dir;
  }

  String _hashKey(
      String provider, String text, String voice, double speed, double pitch) {
    final digest =
        sha1.convert(utf8.encode('$provider|$voice|$speed|$pitch|$text'));
    return digest.toString();
  }

  String _azureVoiceName(String v) {
    // Accept either 'fr-FR' (default to DeniseNeural) or full name like 'fr-FR-DeniseNeural'
    final s = v.replaceAll('_', '-');
    if (s.split('-').length >= 3) return s; // already a full voice name
    final lang = s.contains('-') ? s : 'fr-FR';
    final map = {
      'fr': 'fr-FR-DeniseNeural',
      'ar': 'ar-SA-HamedNeural',
    };
    final code = lang.split('-').first.toLowerCase();
    return map[code] ?? 'fr-FR-DeniseNeural';
  }

  String _buildSsml(String text,
      {required String voiceName,
      required double speed,
      required double pitch}) {
    // Map speed/pitch to percentages for Azure prosody
    final ratePct =
        ((speed / 0.55) * 100).clamp(50, 200).toStringAsFixed(0); // 0.55 ~100%
    final pitchPct = (((pitch - 1.0) * 100) * 2)
        .clamp(-40, 40)
        .toStringAsFixed(0); // +/- up to 40%
    return '''
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="en-US">
  <voice name="$voiceName">
    <prosody rate="$ratePct%" pitch="$pitchPct%">${_escape(text)}</prosody>
  </voice>
</speak>
''';
  }

  String _escape(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}

class CloudTtsConfig {
  CloudTtsConfig({
    required this.provider,
    this.apiKey,
    this.endpoint,
    this.awsAccessKey,
    this.awsSecretKey,
  });
  final String provider; // 'google' | 'azure' | 'polly'
  final String? apiKey; // google/azure
  final String? endpoint; // azure region, or polly region
  final String? awsAccessKey; // polly
  final String? awsSecretKey; // polly
  @override
  bool operator ==(Object other) =>
      other is CloudTtsConfig &&
      other.provider == provider &&
      other.apiKey == apiKey &&
      other.endpoint == endpoint &&
      other.awsAccessKey == awsAccessKey &&
      other.awsSecretKey == awsSecretKey;
  @override
  int get hashCode =>
      Object.hash(provider, apiKey, endpoint, awsAccessKey, awsSecretKey);
}

// Riverpod providers
final cloudTtsProvider =
    Provider.family<CloudTtsService, String>((ref, apiKey) {
  return GoogleCloudTtsService(apiKey);
});

final cloudTtsByConfigProvider =
    Provider.family<CloudTtsService, CloudTtsConfig>((ref, cfg) {
  switch (cfg.provider) {
    case 'azure':
      final region =
          (cfg.endpoint ?? '').isNotEmpty ? cfg.endpoint! : 'westeurope';
      return AzureCloudTtsService(cfg.apiKey ?? '', region);
    case 'polly':
      final region =
          (cfg.endpoint ?? '').isNotEmpty ? cfg.endpoint! : 'eu-west-1';
      return AwsPollyTtsService(
        accessKey: cfg.awsAccessKey ?? '',
        secretKey: cfg.awsSecretKey ?? '',
        region: region,
      );
    case 'google':
    default:
      return GoogleCloudTtsService(cfg.apiKey ?? '');
  }
});
