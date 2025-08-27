import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class CaptureService {
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  Future<File?> takePhoto() async {
    final xfile = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (xfile == null) return null;
    return File(xfile.path);
  }

  Future<File?> pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['wav','mp3','m4a','aac']);
    if (res == null || res.files.isEmpty || res.files.single.path == null) return null;
    return File(res.files.single.path!);
  }

  Future<File?> startRecording() async {
    if (!await _recorder.hasPermission()) return null;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    return File(path);
  }

  Future<File?> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    return File(path);
  }
}

