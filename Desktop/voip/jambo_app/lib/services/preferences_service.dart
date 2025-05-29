import 'package:shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;

  late SharedPreferences _prefs;

  PreferencesService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Thème
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
  }

  bool getDarkMode() {
    return _prefs.getBool('darkMode') ?? false;
  }

  // Son
  Future<void> setDialpadSound(bool value) async {
    await _prefs.setBool('dialpadSound', value);
  }

  bool getDialpadSound() {
    return _prefs.getBool('dialpadSound') ?? true;
  }

  // Vibration
  Future<void> setVibration(bool value) async {
    await _prefs.setBool('vibration', value);
  }

  bool getVibration() {
    return _prefs.getBool('vibration') ?? true;
  }

  // Paramètres d'appel
  Future<void> setCallSettings(Map<String, dynamic> settings) async {
    await _prefs.setString('callSettings', jsonEncode(settings));
  }

  Map<String, dynamic> getCallSettings() {
    final String? settingsJson = _prefs.getString('callSettings');
    if (settingsJson == null) {
      return {
        'autoAnswer': false,
        'speakerDefault': false,
        'recordCalls': false,
      };
    }
    return jsonDecode(settingsJson);
  }

  // Profil utilisateur
  Future<void> setUserProfile(Map<String, dynamic> profile) async {
    await _prefs.setString('userProfile', jsonEncode(profile));
  }

  Map<String, dynamic> getUserProfile() {
    final String? profileJson = _prefs.getString('userProfile');
    if (profileJson == null) {
      return {
        'name': '',
        'email': '',
        'phoneNumber': '',
        'profileImage': null,
      };
    }
    return jsonDecode(profileJson);
  }

  // Nettoyage des données
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
