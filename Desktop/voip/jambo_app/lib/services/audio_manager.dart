import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  FlutterSoundPlayer? _player;
  FlutterSoundRecorder? _recorder;
  bool _isPlayerInitialized = false;
  bool _isRecorderInitialized = false;
  StreamSubscription? _recorderSubscription;

  final _volumeController = StreamController<double>.broadcast();
  Stream<double> get volumeStream => _volumeController.stream;

  AudioManager._internal();

  Future<void> initialize() async {
    // Initialisation du lecteur
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
    _isPlayerInitialized = true;

    // Initialisation de l'enregistreur
    if (await Permission.microphone.request().isGranted) {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;

      // Écoute du niveau sonore
      _recorderSubscription = _recorder!.onProgress!.listen((e) {
        if (e.decibels != null) {
          _volumeController.add(e.decibels! / 100);
        }
      });
    }
  }

  Future<void> startMicrophone() async {
    if (!_isRecorderInitialized) return;

    await _recorder!.startRecorder(
      toStream: true,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 8000,
    );
  }

  Future<void> stopMicrophone() async {
    if (!_isRecorderInitialized) return;
    await _recorder!.stopRecorder();
  }

  Future<void> startSpeaker() async {
    if (!_isPlayerInitialized) return;

    await _player!.startPlayer(
      fromStream: true,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 8000,
    );
  }

  Future<void> stopSpeaker() async {
    if (!_isPlayerInitialized) return;
    await _player!.stopPlayer();
  }

  Future<void> setVolume(double volume) async {
    if (_isPlayerInitialized) {
      await _player!.setVolume(volume);
    }
  }

  Future<void> dispose() async {
    _recorderSubscription?.cancel();
    _volumeController.close();

    if (_isPlayerInitialized) {
      await _player!.closePlayer();
      _player = null;
    }

    if (_isRecorderInitialized) {
      await _recorder!.closeRecorder();
      _recorder = null;
    }
  }
}
