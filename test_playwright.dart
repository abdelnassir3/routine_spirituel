import 'dart:io';

/// Simple test script to verify the app can be built
/// This will help us validate our fixes before running full Playwright tests
void main() async {
  print('🧪 Testing Flutter app compilation...');
  
  // Clean first
  print('🧹 Cleaning build artifacts...');
  final cleanResult = await Process.run('flutter', ['clean']);
  if (cleanResult.exitCode != 0) {
    print('❌ Flutter clean failed: ${cleanResult.stderr}');
    exit(1);
  }
  
  // Get dependencies
  print('📦 Getting dependencies...');
  final pubGetResult = await Process.run('flutter', ['pub', 'get']);
  if (pubGetResult.exitCode != 0) {
    print('❌ Flutter pub get failed: ${pubGetResult.stderr}');
    exit(1);
  }
  
  // Try to compile for web
  print('🌐 Compiling for web...');
  final buildResult = await Process.run('flutter', [
    'build', 
    'web', 
    '--web-renderer=canvaskit',
    '--debug'
  ]);
  
  if (buildResult.exitCode == 0) {
    print('✅ Flutter web compilation successful!');
    print('📄 Build output location: build/web/');
    
    // Start a simple HTTP server to serve the built app
    print('🚀 Starting local server on port 8080...');
    final serverResult = await Process.start('python3', [
      '-m', 'http.server', '8080', '--directory', 'build/web/'
    ]);
    
    print('🌐 App available at: http://localhost:8080');
    print('⏹️ Press Ctrl+C to stop the server');
    
    // Wait for the server process
    await serverResult.exitCode;
    
  } else {
    print('❌ Flutter web compilation failed:');
    print('STDOUT: ${buildResult.stdout}');
    print('STDERR: ${buildResult.stderr}');
    exit(1);
  }
}