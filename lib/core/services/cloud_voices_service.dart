import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';

import 'package:spiritual_routines/core/services/audio_cloud_tts_service.dart';

class CloudVoice {
  final String name;
  final String locale;
  final String? gender;
  const CloudVoice({required this.name, required this.locale, this.gender});
}

class CloudVoicesService {
  CloudVoicesService({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  Future<List<CloudVoice>> listVoices(CloudTtsConfig cfg) async {
    switch (cfg.provider) {
      case 'azure':
        return _listAzure(cfg.apiKey ?? '', cfg.endpoint ?? 'westeurope');
      case 'polly':
        return _listPolly(cfg.awsAccessKey ?? '', cfg.awsSecretKey ?? '',
            cfg.endpoint ?? 'eu-west-1');
      case 'google':
      default:
        return _listGoogle(cfg.apiKey ?? '');
    }
  }

  Future<List<CloudVoice>> _listGoogle(String apiKey) async {
    final url = 'https://texttospeech.googleapis.com/v1/voices?key=$apiKey';
    final resp = await _dio.get(url);
    final list = (resp.data['voices'] as List?) ?? const [];
    final voices = list.map((v) {
      final name = (v['name'] ?? '').toString();
      final loc = (v['languageCodes'] is List &&
              (v['languageCodes'] as List).isNotEmpty)
          ? (v['languageCodes'] as List).first.toString()
          : (v['languageCodes']?.toString() ?? '');
      final gender = (v['ssmlGender'] ?? '').toString();
      return CloudVoice(
          name: name, locale: loc, gender: gender.isEmpty ? null : gender);
    }).toList();
    voices.sort((a, b) {
      int score(CloudVoice v) {
        final n = v.name.toLowerCase();
        int s = 0;
        if (n.contains('neural2') || n.contains('wavenet')) s += 2;
        if ((v.gender ?? '').toLowerCase() == 'female') s += 1;
        return -s; // higher score first
      }

      final c = score(a).compareTo(score(b));
      if (c != 0) return c;
      return a.name.compareTo(b.name);
    });
    return voices;
  }

  Future<List<CloudVoice>> _listAzure(String apiKey, String region) async {
    final url =
        'https://$region.tts.speech.microsoft.com/cognitiveservices/voices/list';
    final resp = await _dio.get(url,
        options: Options(headers: {'Ocp-Apim-Subscription-Key': apiKey}));
    final list = resp.data as List<dynamic>;
    final voices = list.map((v) {
      final name = (v['ShortName'] ?? v['Name'] ?? '').toString();
      final loc = (v['Locale'] ?? '').toString();
      final gender = (v['Gender'] ?? '').toString();
      return CloudVoice(
          name: name, locale: loc, gender: gender.isEmpty ? null : gender);
    }).toList();
    voices.sort((a, b) {
      int score(CloudVoice v) {
        int s = 0;
        if (v.name.contains('Neural')) s += 2;
        if ((v.gender ?? '').toLowerCase() == 'Female'.toLowerCase()) s += 1;
        return -s;
      }

      final c = score(a).compareTo(score(b));
      if (c != 0) return c;
      return a.name.compareTo(b.name);
    });
    return voices;
  }

  Future<List<CloudVoice>> _listPolly(
      String accessKey, String secretKey, String region) async {
    final host = 'polly.$region.amazonaws.com';
    final url = 'https://$host/v1/voices?Engine=neural';
    // SigV4 for GET with empty payload
    final t = DateTime.now().toUtc();
    final amzDate = _fmtAmz(t);
    final dateStamp = _fmtDate(t);
    const service = 'polly';
    const algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = '$dateStamp/$region/$service/aws4_request';
    const canonicalUri = '/v1/voices';
    const canonicalQueryString = 'Engine=neural';
    final canonicalHeaders = 'host:$host\n' 'x-amz-date:$amzDate\n';
    const signedHeaders = 'host;x-amz-date';
    final payloadHash = sha256.convert(utf8.encode('')).toString();
    final canonicalRequest = [
      'GET',
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
    final resp = await _dio.get(url,
        options: Options(
            headers: {'x-amz-date': amzDate, 'Authorization': authorization}));
    final list = (resp.data['Voices'] as List?) ?? const [];
    final voices = list.map((v) {
      final name = (v['Id'] ?? '').toString();
      final loc = (v['LanguageCode'] ?? '').toString();
      final gender = (v['Gender'] ?? '').toString();
      return CloudVoice(
          name: name, locale: loc, gender: gender.isEmpty ? null : gender);
    }).toList();
    voices.sort((a, b) {
      int score(CloudVoice v) {
        int s = 1; // all neural in this endpoint
        if ((v.gender ?? '').toLowerCase() == 'female') s += 1;
        return -s;
      }

      final c = score(a).compareTo(score(b));
      if (c != 0) return c;
      return a.name.compareTo(b.name);
    });
    return voices;
  }

  String _fmtAmz(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}T${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}${t.second.toString().padLeft(2, '0')}Z';
  String _fmtDate(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}';
}

final cloudVoicesServiceProvider =
    Provider<CloudVoicesService>((ref) => CloudVoicesService());
final cloudVoicesByConfigProvider =
    FutureProvider.family<List<CloudVoice>, CloudTtsConfig>((ref, cfg) async {
  final svc = ref.read(cloudVoicesServiceProvider);
  return svc.listVoices(cfg);
});
