enum CallState { idle, calling, ringing, connected, ended, failed }

class CallStateInfo {
  final CallState state;
  final String phoneNumber;
  final DateTime startTime;
  final String? errorMessage;

  CallStateInfo({
    required this.state,
    required this.phoneNumber,
    required this.startTime,
    this.errorMessage,
  });
}
