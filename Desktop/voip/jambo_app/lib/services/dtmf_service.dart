import 'package:just_audio/just_audio.dart';

class DtmfService {
  static final DtmfService _instance = DtmfService._internal();
  factory DtmfService() => _instance;

  final _player = AudioPlayer();
  final Map<String, String> _toneAssets = {
    '1': 'assets/sounds/dtmf-1.wav',
    '2': 'assets/sounds/dtmf-2.wav',
    '3': 'assets/sounds/dtmf-3.wav',
    '4': 'assets/sounds/dtmf-4.wav',
    '5': 'assets/sounds/dtmf-5.wav',
    '6': 'assets/sounds/dtmf-6.wav',
    '7': 'assets/sounds/dtmf-7.wav',
    '8': 'assets/sounds/dtmf-8.wav',
    '9': 'assets/sounds/dtmf-9.wav',
    '0': 'assets/sounds/dtmf-0.wav',
    '*': 'assets/sounds/dtmf-star.wav',
    '#': 'assets/sounds/dtmf-pound.wav',
  };

  DtmfService._internal();

  Future<void> playTone(String digit) async {
    if (_toneAssets.containsKey(digit)) {
      try {
        await _player.setAsset(_toneAssets[digit]!);
        await _player.play();
      } catch (e) {
        print('Erreur lors de la lecture du ton DTMF: $e');
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}
