import 'package:flutter_dtmf/flutter_dtmf.dart';

class DialpadTones {
  static final FlutterDtmf _dtmf = FlutterDtmf();

  static void playTone(String digit) {
    _dtmf.playTone(
      toneString: digit,
      durationMs: 200,
      volume: 1.0,
    );
  }

  static Map<String, List<double>> get frequencies => {
        '1': [697, 1209],
        '2': [697, 1336],
        '3': [697, 1477],
        '4': [770, 1209],
        '5': [770, 1336],
        '6': [770, 1477],
        '7': [852, 1209],
        '8': [852, 1336],
        '9': [852, 1477],
        '*': [941, 1209],
        '0': [941, 1336],
        '#': [941, 1477],
      };
}
