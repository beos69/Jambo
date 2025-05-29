class CallLog {
  final int? id;
  final String number;
  final DateTime timestamp;
  final int duration;
  final String status;
  final String type;

  CallLog({
    this.id,
    required this.number,
    required this.timestamp,
    required this.duration,
    required this.status,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
      'status': status,
      'type': type,
    };
  }

  factory CallLog.fromMap(Map<String, dynamic> map) {
    return CallLog(
      id: map['id'],
      number: map['number'],
      timestamp: DateTime.parse(map['timestamp']),
      duration: map['duration'],
      status: map['status'],
      type: map['type'],
    );
  }
}
