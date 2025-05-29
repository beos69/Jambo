import 'package:permission_handler/permission_handler.dart';

Future<void> requestAudioPermissions() async {
  await Permission.microphone.request();
  await Permission.storage.request();
}
