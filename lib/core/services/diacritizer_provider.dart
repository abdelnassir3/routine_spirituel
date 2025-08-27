import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spiritual_routines/core/services/diacritizer_http.dart';
import 'package:spiritual_routines/core/services/diacritizer_service.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';

final diacritizerProvider = FutureProvider<DiacritizerService>((ref) async {
  final settings = ref.read(userSettingsServiceProvider);
  final mode = await settings.getDiacritizerMode();
  if (mode == 'api') {
    final endpoint = await settings.getDiacritizerEndpoint();
    if (endpoint != null && endpoint.startsWith('http')) {
      return HttpDiacritizerService(endpoint);
    }
  }
  return StubDiacritizerService();
});
