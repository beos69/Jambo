import 'package:flutter/material.dart';
import '../utils/dialpad_tones.dart';
import '../services/vibration_service.dart';

class KeypadWidget extends StatelessWidget {
  final Function(String) onKeyPressed;
  final Function(String) onKeyLongPressed;
  final bool enableSound;
  final bool enableVibration;
  final double buttonSize;
  final double fontSize;

  const KeypadWidget({
    Key? key,
    required this.onKeyPressed,
    required this.onKeyLongPressed,
    this.enableSound = true,
    this.enableVibration = true,
    this.buttonSize = 70.0,
    this.fontSize = 24.0,
  }) : super(key: key);

  void _handleKeyPress(String key) {
    if (enableSound) {
      DialpadTones.playTone(key);
    }
    if (enableVibration) {
      VibrationService().vibrate();
    }
    onKeyPressed(key);
  }

  Widget _buildKey(String number, String letters) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: MaterialButton(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(0),
        onPressed: () => _handleKeyPress(number),
        onLongPress: () => onKeyLongPressed(number),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: TextStyle(
                  fontSize: fontSize * 0.4,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('1', 'VOICEMAIL'),
              _buildKey('2', 'ABC'),
              _buildKey('3', 'DEF'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('4', 'GHI'),
              _buildKey('5', 'JKL'),
              _buildKey('6', 'MNO'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('7', 'PQRS'),
              _buildKey('8', 'TUV'),
              _buildKey('9', 'WXYZ'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('*', ''),
              _buildKey('0', '+'),
              _buildKey('#', ''),
            ],
          ),
        ],
      ),
    );
  }
}
