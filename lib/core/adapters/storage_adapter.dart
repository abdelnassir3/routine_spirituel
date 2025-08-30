/// Interface abstraite pour le stockage sécurisé multi-plateforme
abstract class StorageAdapter {
  /// Stocker une valeur de manière sécurisée
  Future<void> write({
    required String key,
    required String value,
  });

  /// Lire une valeur stockée
  Future<String?> read({required String key});

  /// Supprimer une valeur
  Future<void> delete({required String key});

  /// Supprimer toutes les valeurs stockées
  Future<void> deleteAll();

  /// Vérifier si une clé existe
  Future<bool> containsKey({required String key});

  /// Obtenir toutes les clés stockées
  Future<Set<String>> readAll();

  /// Chiffrer et stocker des données sensibles (tokens, passwords)
  Future<void> writeSecure({
    required String key,
    required String value,
    String? groupId,
  });

  /// Lire des données chiffrées
  Future<String?> readSecure({
    required String key,
    String? groupId,
  });

  /// Vérifier si le stockage sécurisé est disponible
  bool get isSecureStorageAvailable;

  /// Vérifier si le stockage supporte le chiffrement
  bool get supportsEncryption;
}
