import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> ensureCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> ensureMic() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> ensureStorage() async {
    final status = await Permission.storage.request();
    return status.isGranted || status.isLimited;
  }
}
