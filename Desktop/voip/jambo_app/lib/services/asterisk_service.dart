import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AsteriskService {
  static final AsteriskService _instance = AsteriskService._internal();
  factory AsteriskService() => _instance;

  final String baseUrl = 'http://192.168.1.28:8088';
  bool _isConnected = false;
  final _stateController = StreamController<bool>.broadcast();

  Stream<bool> get connectionState => _stateController.stream;
  bool get isConnected => _isConnected;

  AsteriskService._internal();

  Future<void> makeCall(String phoneNumber) async {
    try {
      debugPrint('Initiation appel vers: $phoneNumber');

      final response = await http.post(
        Uri.parse('$baseUrl/ari/channels'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'Originate',
          'channel': 'Local/$phoneNumber@from-internal',
          'context': 'from-internal',
          'priority': 1,
          'async': true,
          'variables': {
            'PHONE_NUMBER': phoneNumber,
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Appel initié avec succès');
      } else {
        throw Exception('Échec de l\'initiation de l\'appel: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel: $e');
      rethrow;
    }
  }

  Future<void> endCall() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ari/channels'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'Hangup',
          'channel': 'all',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Appel terminé avec succès');
      } else {
        throw Exception(
            'Échec de la terminaison de l\'appel: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la terminaison de l\'appel: $e');
      rethrow;
    }
  }

  void dispose() {
    _stateController.close();
  }
}
