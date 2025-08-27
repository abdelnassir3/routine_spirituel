import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spiritual_routines/core/platform/platform_service.dart';

/// Wrapper pour les permissions qui fonctionne sur toutes les plateformes
class PermissionWrapper {
  final PlatformService _platform = PlatformService.instance;

  /// Demande une permission de manière cross-platform
  Future<bool> requestPermission(Permission permission) async {
    // Sur web, pas de permissions
    if (kIsWeb) {
      return true;
    }

    // Sur desktop (macOS), certaines permissions sont gérées différemment
    if (_platform.isMacOS) {
      return await _requestMacOSPermission(permission);
    }

    // Sur Windows/Linux, la plupart des permissions ne sont pas nécessaires
    if (_platform.isWindows || _platform.isLinux) {
      return await _requestDesktopPermission(permission);
    }

    // Sur mobile (iOS/Android), utiliser permission_handler normalement
    if (_platform.isMobile) {
      final status = await permission.request();
      return status.isGranted || status.isLimited;
    }

    return true;
  }

  /// Gestion spécifique des permissions macOS
  Future<bool> _requestMacOSPermission(Permission permission) async {
    // Sur macOS, les permissions sont gérées via les entitlements
    // et les autorisations système

    if (permission == Permission.camera) {
      // Vérifier si l'entitlement camera est présent
      if (!_platform.supportsCamera) {
        debugPrint('Camera non supportée sur macOS en release');
        return false;
      }
      // La permission sera demandée automatiquement au premier usage
      return true;
    }

    if (permission == Permission.microphone) {
      // La permission microphone sera demandée au premier usage
      return true;
    }

    if (permission == Permission.photos) {
      // Accès à la photothèque via entitlements
      return true;
    }

    if (permission == Permission.storage) {
      // Sur macOS, utiliser le sandbox avec file picker
      // Pas besoin de permission explicite
      return true;
    }

    // Autres permissions non applicables sur macOS
    return true;
  }

  /// Gestion des permissions sur Windows/Linux
  Future<bool> _requestDesktopPermission(Permission permission) async {
    // Sur Windows et Linux, la plupart des permissions
    // ne sont pas gérées de la même manière que sur mobile

    if (permission == Permission.storage) {
      // Accès fichiers direct sur desktop
      return true;
    }

    if (permission == Permission.camera ||
        permission == Permission.microphone) {
      // Généralement disponible sans permission explicite
      return true;
    }

    // Autres permissions non applicables
    return true;
  }

  /// Vérifie si une permission est nécessaire sur cette plateforme
  bool isPermissionRequired(Permission permission) {
    if (permission == Permission.camera) {
      return _platform.needsCameraPermission;
    }

    if (permission == Permission.microphone) {
      return _platform.needsMicrophonePermission;
    }

    if (permission == Permission.storage) {
      return _platform.needsStoragePermission;
    }

    if (permission == Permission.notification) {
      return _platform.needsNotificationPermission;
    }

    // Par défaut, permission nécessaire sur mobile uniquement
    return _platform.isMobile;
  }

  /// Obtient le statut d'une permission
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    if (kIsWeb) {
      return PermissionStatus.granted;
    }

    // Sur desktop non-macOS, toujours accordé
    if (_platform.isWindows || _platform.isLinux) {
      return PermissionStatus.granted;
    }

    // Sur macOS, vérifier selon le type
    if (_platform.isMacOS) {
      if (permission == Permission.camera && !_platform.supportsCamera) {
        return PermissionStatus.permanentlyDenied;
      }
      // Pour les autres, supposer accordé (sera vérifié à l'usage)
      return PermissionStatus.granted;
    }

    // Sur mobile, utiliser permission_handler
    if (_platform.isMobile) {
      return await permission.status;
    }

    return PermissionStatus.granted;
  }

  /// Demande plusieurs permissions en une fois
  Future<Map<Permission, bool>> requestMultiplePermissions(
      List<Permission> permissions) async {
    final results = <Permission, bool>{};

    for (final permission in permissions) {
      if (isPermissionRequired(permission)) {
        results[permission] = await requestPermission(permission);
      } else {
        results[permission] = true;
      }
    }

    return results;
  }

  /// Ouvre les paramètres de l'application
  Future<bool> openSettings() async {
    if (_platform.isMobile) {
      return await openAppSettings();
    }

    if (_platform.isMacOS) {
      debugPrint('Pour modifier les permissions sur macOS :');
      debugPrint('Ouvrez Préférences Système > Sécurité et confidentialité');
      return false;
    }

    if (_platform.isWindows) {
      debugPrint('Pour modifier les permissions sur Windows :');
      debugPrint('Ouvrez Paramètres > Confidentialité');
      return false;
    }

    return false;
  }

  /// Message d'erreur adapté à la plateforme
  String getPermissionDeniedMessage(Permission permission) {
    String permissionName = '';

    if (permission == Permission.camera) {
      permissionName = 'la caméra';
    } else if (permission == Permission.microphone) {
      permissionName = 'le microphone';
    } else if (permission == Permission.storage) {
      permissionName = 'le stockage';
    } else if (permission == Permission.photos) {
      permissionName = 'les photos';
    }

    return _platform.getPermissionErrorMessage(permissionName);
  }
}
