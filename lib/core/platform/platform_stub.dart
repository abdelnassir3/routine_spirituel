/// Stub pour Platform sur Web
/// Ce fichier fournit une implémentation factice de Platform pour le Web

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isFuchsia => false;

  static String get operatingSystem => 'web';
  static String get operatingSystemVersion => '';
  static String get localHostname => '';
  static Map<String, String> get environment => {};
  static String get executable => '';
  static String get resolvedExecutable => '';
  static Uri get script => Uri.parse('');
  static List<String> get executableArguments => [];
  static String get packageRoot => '';
  static String get packageConfig => '';
  static String get version => '';
  static String get localeName => '';

  static int get numberOfProcessors => 1;
  static String get pathSeparator => '/';
}

// Stub pour File sur Web
class File {
  final String path;

  File(this.path);

  Future<bool> exists() async => false;
  Future<String> readAsString() async => '';
  Future<List<int>> readAsBytes() async => [];
  Future<void> writeAsString(String contents) async {}
  Future<void> writeAsBytes(List<int> bytes) async {}
}

// Stub pour Directory sur Web
class Directory {
  final String path;

  Directory(this.path);

  Future<bool> exists() async => false;
  Future<Directory> create({bool recursive = false}) async => this;
  Future<void> delete({bool recursive = false}) async {}
}
