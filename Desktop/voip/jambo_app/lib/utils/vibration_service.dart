import 'package:vibration/vibration.dart';

class VibrationService {
  static final VibrationService _instance = VibrationService._internal();
  factory VibrationService() => _instance;

  VibrationService._internal();

  Future<void> vibrate({Pattern? pattern}) async {
    if (await Vibration.hasVibrator() ?? false) {
      if (pattern != null) {
        Vibration.vibrate(pattern: pattern);
      } else {
        Vibration.vibrate();
      }
    }
  }

  void cancelVibration() {
    Vibration.cancel();
  }

  static const Pattern callPattern = [500, 1000, 500, 1000];
  static const Pattern notificationPattern = [100, 200, 100, 200];
  static const Pattern errorPattern = [100, 100, 100];
}
