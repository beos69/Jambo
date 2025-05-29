import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;

  final String baseUrl = 'http://192.168.1.28:5000';

  CallService._internal();

  Future<bool> makeCall(String phoneNumber) async {
    try {
      debugPrint('Tentative d\'appel vers: $phoneNumber');

      // Appeler directement le script Python via HTTP
      final response = await http.post(
        Uri.parse('$baseUrl/call'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Appel initié avec succès');
        return true;
      } else {
        debugPrint('Échec de l\'appel: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel: $e');
      return false;
    }
  }

  Future<bool> endCall() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hangup'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur lors de la fin d\'appel: $e');
      return false;
    }
  }
}
