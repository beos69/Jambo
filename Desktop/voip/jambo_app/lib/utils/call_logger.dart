import 'dart:developer' as developer;
import '../models/call_log.dart';
import '../services/database_helper.dart';

class CallLogger {
  static final CallLogger _instance = CallLogger._internal();
  factory CallLogger() => _instance;

  CallLogger._internal();

  Future<void> logCall({
    required String phoneNumber,
    required int duration,
    required String status,
    required String type,
  }) async {
    try {
      final callLog = CallLog(
        number: phoneNumber,
        timestamp: DateTime.now(),
        duration: duration,
        status: status,
        type: type,
      );

      await DatabaseHelper.instance.insertCallLog(callLog);

      developer.log(
        'Call logged successfully',
        name: 'CallLogger',
        time: DateTime.now(),
        error: null,
        stackTrace: null,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error logging call',
        name: 'CallLogger',
        time: DateTime.now(),
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
