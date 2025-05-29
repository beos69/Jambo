import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/call_state.dart';

class CallStateManager extends ChangeNotifier {
  CallStateInfo? _currentCallState;
  Timer? _callDurationTimer;
  int _callDuration = 0;
  final _callStateController = StreamController<CallStateInfo>.broadcast();

  CallStateInfo? get currentCallState => _currentCallState;
  int get callDuration => _callDuration;
  Stream<CallStateInfo> get callStateStream => _callStateController.stream;

  void updateCallState(CallStateInfo newState) {
    _currentCallState = newState;
    _callStateController.add(newState);

    if (newState.state == CallState.connected) {
      _startCallDurationTimer();
    } else if (newState.state == CallState.ended ||
        newState.state == CallState.failed) {
      _stopCallDurationTimer();
    }

    notifyListeners();
  }

  void _startCallDurationTimer() {
    _callDuration = 0;
    _callDurationTimer?.cancel();
    _callDurationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _callDuration++;
        notifyListeners();
      },
    );
  }

  void _stopCallDurationTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
  }

  String get formattedDuration {
    final minutes = (_callDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void reset() {
    _stopCallDurationTimer();
    _callDuration = 0;
    _currentCallState = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopCallDurationTimer();
    _callStateController.close();
    super.dispose();
  }
}
