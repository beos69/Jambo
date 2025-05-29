import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  FlutterSoundPlayer? _player;
  bool _isInitialized = false;

  AudioService._internal();

  Future<void> initialize() async {
    if (!_isInitialized) {
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      _isInitialized = true;
    }
  }

  Future<void> playRingtone() async {
    if (!_isInitialized) await initialize();

    if (await Permission.storage.isGranted) {
      await _player!.startPlayer(
        fromURI: 'asset://assets/sounds/ringtone.mp3',
        whenFinished: () {
          // Répéter le son si nécessaire
          playRingtone();
        },
      );
    }
  }

  Future<void> stopRingtone() async {
    if (_isInitialized && _player!.isPlaying) {
      await _player!.stopPlayer();
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _player!.closePlayer();
      _player = null;
      _isInitialized = false;
    }
  }
}
