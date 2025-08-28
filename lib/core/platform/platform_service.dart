import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;

/// Service de gestion des différences entre plateformes
class PlatformService {
  static PlatformService? _instance;

  PlatformService._();

  static PlatformService get instance {
    _instance ??= PlatformService._();
    return _instance!;
  }

  // Détection de la plateforme courante
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isLinux => !kIsWeb && Platform.isLinux;
  bool get isWeb => kIsWeb;

  // Détection des catégories de plateforme
  bool get isMobile => isIOS || isAndroid;
  bool get isDesktop => isMacOS || isWindows || isLinux;
  bool get isApple => isIOS || isMacOS;

  // Capacités de la plateforme
  bool get supportsCamera => isMobile || (isMacOS && !kReleaseMode);
  bool get supportsMicrophone => true; // Toutes les plateformes
  bool get supportsOCR => isMobile; // google_mlkit est mobile only
  bool get supportsFilePicker => true; // Toutes les plateformes
  bool get supportsNotifications => isMobile || isMacOS;
  bool get supportsBackgroundAudio => isMobile; // audio_service est mobile only
  bool get supportsBiometrics => isMobile || (isMacOS && !kIsWeb);

  // Configuration des permissions
  bool get needsExplicitPermissions => isMobile || isMacOS;
  bool get needsCameraPermission => supportsCamera && needsExplicitPermissions;
  bool get needsMicrophonePermission =>
      supportsMicrophone && needsExplicitPermissions;
  bool get needsStoragePermission =>
      isAndroid; // iOS/macOS utilisent le sandbox
  bool get needsNotificationPermission =>
      supportsNotifications && needsExplicitPermissions;

  // Chemins spécifiques à la plateforme
  String get documentsPath {
    if (isIOS || isMacOS) {
      return 'Documents'; // Dans le container de l'app
    } else if (isAndroid) {
      return 'Documents'; // Dans le stockage externe
    } else if (isWindows) {
      return 'Documents'; // Dans AppData
    } else {
      return 'Documents'; // Linux: dans home
    }
  }

  // Comportements UI spécifiques
  bool get useCupertinoDesign => isApple;
  bool get useCompactLayout => isMobile;
  bool get supportsDragAndDrop => isDesktop;
  bool get supportsHoverEffects => isDesktop || isWeb;
  bool get supportsKeyboardShortcuts => isDesktop || isWeb;
  bool get supportsMultiWindow =>
      isDesktop && !isMacOS; // macOS a des restrictions

  // Tailles et contraintes
  double get minWindowWidth => isDesktop ? 800 : 0;
  double get minWindowHeight => isDesktop ? 600 : 0;
  double get defaultFontSize => isMobile ? 14 : 15;
  double get defaultIconSize => isMobile ? 24 : 20;
  double get defaultPadding => isMobile ? 16 : 20;

  // Audio/TTS spécifique
  bool get needsAudioFocus => isMobile;
  bool get supportsBackgroundTTS => isMobile;
  double get defaultTTSRate => isIOS ? 0.5 : 0.55;
  String get defaultTTSLanguageAR => 'ar-SA';
  String get defaultTTSLanguageFR => isApple ? 'fr-FR' : 'fr-fr';

  // Gestion des erreurs spécifiques
  String getPermissionErrorMessage(String permission) {
    if (isMacOS) {
      return 'Veuillez autoriser $permission dans Préférences Système > Sécurité et confidentialité';
    } else if (isIOS) {
      return 'Veuillez autoriser $permission dans Réglages > Confidentialité';
    } else if (isAndroid) {
      return 'Veuillez autoriser $permission dans Paramètres > Applications';
    } else {
      return 'Veuillez autoriser $permission dans les paramètres système';
    }
  }

  // Méthode pour obtenir la configuration adaptée
  Map<String, dynamic> getPlatformConfig() {
    return {
      'platform': {
        'isIOS': isIOS,
        'isMacOS': isMacOS,
        'isAndroid': isAndroid,
        'isWindows': isWindows,
        'isLinux': isLinux,
        'isWeb': isWeb,
      },
      'capabilities': {
        'camera': supportsCamera,
        'microphone': supportsMicrophone,
        'ocr': supportsOCR,
        'filePicker': supportsFilePicker,
        'notifications': supportsNotifications,
        'backgroundAudio': supportsBackgroundAudio,
        'biometrics': supportsBiometrics,
      },
      'ui': {
        'useCupertino': useCupertinoDesign,
        'compactLayout': useCompactLayout,
        'dragAndDrop': supportsDragAndDrop,
        'hoverEffects': supportsHoverEffects,
        'keyboardShortcuts': supportsKeyboardShortcuts,
      },
      'dimensions': {
        'minWindowWidth': minWindowWidth,
        'minWindowHeight': minWindowHeight,
        'defaultFontSize': defaultFontSize,
        'defaultIconSize': defaultIconSize,
        'defaultPadding': defaultPadding,
      },
    };
  }
}

// Provider pour Riverpod
final platformServiceProvider = Provider<PlatformService>((ref) {
  return PlatformService.instance;
});
