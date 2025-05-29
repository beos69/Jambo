import 'package:shared_preferences.dart';
import 'dart:convert';
import '../models/call_log.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  final String _storageKey = 'call_analytics';
  late SharedPreferences _prefs;

  AnalyticsService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> logCall(CallLog call) async {
    final analytics = await _getAnalytics();

    // Mettre à jour les statistiques
    analytics['total_calls'] = (analytics['total_calls'] ?? 0) + 1;
    analytics['total_duration'] =
        (analytics['total_duration'] ?? 0) + call.duration;

    // Statistiques par type
    final typeStats = analytics['call_types'] ?? {};
    typeStats[call.type] = (typeStats[call.type] ?? 0) + 1;
    analytics['call_types'] = typeStats;

    // Statistiques par statut
    final statusStats = analytics['call_status'] ?? {};
    statusStats[call.status] = (statusStats[call.status] ?? 0) + 1;
    analytics['call_status'] = statusStats;

    // Statistiques horaires
    final hourlyStats = analytics['hourly_stats'] ?? {};
    final hour = call.timestamp.hour.toString();
    hourlyStats[hour] = (hourlyStats[hour] ?? 0) + 1;
    analytics['hourly_stats'] = hourlyStats;

    await _saveAnalytics(analytics);
  }

  Future<Map<String, dynamic>> getCallStatistics() async {
    return await _getAnalytics();
  }

  Future<Map<String, dynamic>> getCallDistribution() async {
    final analytics = await _getAnalytics();
    return {
      'types': analytics['call_types'] ?? {},
      'status': analytics['call_status'] ?? {},
      'hourly': analytics['hourly_stats'] ?? {},
    };
  }

  Future<double> getAverageCallDuration() async {
    final analytics = await _getAnalytics();
    final totalCalls = analytics['total_calls'] ?? 0;
    final totalDuration = analytics['total_duration'] ?? 0;
    return totalCalls > 0 ? totalDuration / totalCalls : 0;
  }

  Future<Map<String, dynamic>> _getAnalytics() async {
    final String? data = _prefs.getString(_storageKey);
    if (data == null) {
      return {};
    }
    return jsonDecode(data);
  }

  Future<void> _saveAnalytics(Map<String, dynamic> analytics) async {
    await _prefs.setString(_storageKey, jsonEncode(analytics));
  }

  Future<void> resetAnalytics() async {
    await _prefs.remove(_storageKey);
  }
}
