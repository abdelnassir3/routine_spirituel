import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:spiritual_routines/core/platform/platform_service.dart';
import 'package:spiritual_routines/core/platform/permission_wrapper.dart';
import 'package:permission_handler/permission_handler.dart';

/// Wrapper pour le picking de média qui fonctionne sur toutes les plateformes
class MediaPickerWrapper {
  final PlatformService _platform = PlatformService.instance;
  final PermissionWrapper _permissions = PermissionWrapper();
  final ImagePicker _imagePicker = ImagePicker();

  /// Sélectionne une image depuis la galerie ou la caméra
  Future<File?> pickImage({required ImageSource source}) async {
    // Vérifier les permissions nécessaires
    if (source == ImageSource.camera) {
      if (!_platform.supportsCamera) {
        throw UnsupportedError(
            'La caméra n\'est pas disponible sur ${_platform.isDesktop ? "desktop" : "cette plateforme"}');
      }

      final hasPermission =
          await _permissions.requestPermission(Permission.camera);
      if (!hasPermission) {
        throw Exception('Permission caméra refusée');
      }
    }

    // Sur desktop, utiliser file_picker au lieu d'image_picker pour la galerie
    if (_platform.isDesktop && source == ImageSource.gallery) {
      return await _pickImageWithFilePicker();
    }

    // Sur mobile ou pour la caméra, utiliser image_picker
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Erreur picking image: $e');

      // Fallback sur file_picker si image_picker échoue
      if (_platform.isDesktop) {
        return await _pickImageWithFilePicker();
      }
    }

    return null;
  }

  /// Utilise file_picker pour sélectionner une image (desktop)
  Future<File?> _pickImageWithFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        return File(path);
      }
    }

    return null;
  }

  /// Sélectionne plusieurs images
  Future<List<File>> pickMultipleImages() async {
    final List<File> images = [];

    if (_platform.isDesktop) {
      // Sur desktop, utiliser file_picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: true,
      );

      if (result != null) {
        for (final file in result.files) {
          if (file.path != null) {
            images.add(File(file.path!));
          }
        }
      }
    } else {
      // Sur mobile, utiliser image_picker
      try {
        final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        for (final file in pickedFiles) {
          images.add(File(file.path));
        }
      } catch (e) {
        debugPrint('Erreur picking multiple images: $e');
      }
    }

    return images;
  }

  /// Sélectionne un fichier PDF
  Future<File?> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        return File(path);
      }
    }

    return null;
  }

  /// Sélectionne n'importe quel fichier
  Future<File?> pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        return File(path);
      }
    }

    return null;
  }

  /// Sélectionne un dossier (desktop uniquement)
  Future<String?> pickDirectory() async {
    if (!_platform.isDesktop) {
      throw UnsupportedError(
          'La sélection de dossier n\'est disponible que sur desktop');
    }

    return await FilePicker.platform.getDirectoryPath();
  }

  /// Sauvegarde un fichier avec dialogue (desktop)
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    List<String>? allowedExtensions,
  }) async {
    if (!_platform.isDesktop) {
      // Sur mobile, retourner un chemin dans le dossier documents
      final directory = await _getDocumentsDirectory();
      if (directory != null && fileName != null) {
        return '${directory.path}/$fileName';
      }
      return null;
    }

    return await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      allowedExtensions: allowedExtensions,
    );
  }

  /// Obtient le dossier documents de l'application
  Future<Directory?> _getDocumentsDirectory() async {
    try {
      // Utiliser path_provider qui est cross-platform
      // Import dynamique pour éviter les erreurs
      return null; // À implémenter avec path_provider
    } catch (e) {
      debugPrint('Erreur obtention dossier documents: $e');
      return null;
    }
  }

  /// Vérifie si une source est disponible
  bool isSourceAvailable(ImageSource source) {
    if (source == ImageSource.camera) {
      return _platform.supportsCamera;
    }
    return true; // Gallery toujours disponible
  }

  /// Message d'erreur pour les fonctionnalités non supportées
  String getUnsupportedMessage(ImageSource source) {
    if (source == ImageSource.camera && !_platform.supportsCamera) {
      if (_platform.isDesktop) {
        return 'La caméra n\'est pas disponible sur desktop.\n'
            'Vous pouvez sélectionner une image depuis vos fichiers.';
      }
      return 'La caméra n\'est pas disponible sur cette plateforme.';
    }
    return 'Cette fonctionnalité n\'est pas disponible.';
  }
}
