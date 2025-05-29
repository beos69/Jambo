import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';
import '../models/call_log.dart';
import '../services/database_helper.dart';
import '../utils/permissions.dart';
import '../models/call_state.dart';
import '../services/call_service.dart';
import '../services/voip_service.dart';

class AppState with ChangeNotifier {
  List<Contact> _contacts = [];
  List<CallLog> _callLogs = [];
  bool _isDarkMode = false;
  bool _isLoaded = false;
  String _error = '';
  String? _profileImagePath;
  bool _isInCall = false;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  final CallService _callService = CallService();
  final VoipService _voipService = VoipService();

  int _callDuration = 0;
  Timer? _callDurationTimer;

  // Getters
  List<Contact> get contacts => _contacts;
  List<CallLog> get callLogs => _callLogs;
  bool get isDarkMode => _isDarkMode;
  bool get isLoaded => _isLoaded;
  String get error => _error;
  String? get profileImagePath => _profileImagePath;
  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  int get callDuration => _callDuration;

  AppState() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      print('Début du chargement des données');
      await requestAudioPermissions();
      await _loadContacts();
      await _loadCallLogs();
      await _loadPreferences();
      _isLoaded = true;
      print('Chargement des données terminé');
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void _handleCallStateChange(Map<String, dynamic> message) {
    if (message.containsKey('event')) {
      switch (message['event']) {
        case 'CallStarted':
          _isInCall = true;
          _startCallTimer();
          break;
        case 'CallEnded':
          endCall();
          break;
      }
      notifyListeners();
    }
  }

  void _startCallTimer() {
    _callDuration = 0;
    _callDurationTimer?.cancel();
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration++;
      notifyListeners();
    });
  }

  void _stopCallTimer() {
    _callDurationTimer?.cancel();
    _callDuration = 0;
  }

  Future<void> makeCall(String number) async {
    try {
      await _voipService.makeCall(number);

      await addCallLog(CallLog(
        number: number,
        timestamp: DateTime.now(),
        duration: 0,
        status: 'initiated',
        type: 'outgoing',
      ));

      _isInCall = true;
      _startCallTimer();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> endCall() async {
    if (_isInCall) {
      await _voipService.endCall();
      _isInCall = false;
      _isMuted = false;
      _stopCallTimer();
      notifyListeners();
    }
  }

  void toggleMute() {
    if (_isInCall) {
      _voipService.toggleMicrophone();
      _isMuted = !_isMuted;
      notifyListeners();
    }
  }

  void toggleSpeaker() {
    if (_isInCall) {
      _voipService.toggleSpeaker();
      _isSpeakerOn = !_isSpeakerOn;
      notifyListeners();
    }
  }

  Future<void> setProfileImage(String path) async {
    _profileImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
    notifyListeners();
  }

  Future<void> _loadContacts() async {
    try {
      _contacts = await DatabaseHelper.instance.getContacts();
      print('Contacts chargés: ${_contacts.length}');
      if (_contacts.isEmpty) {
        print('Ajout de contacts de test');
        await DatabaseHelper.instance
            .insertContact(Contact(name: 'John Doe', phoneNumber: '123456789'));
        await DatabaseHelper.instance.insertContact(
            Contact(name: 'Jane Smith', phoneNumber: '987654321'));
        _contacts = await DatabaseHelper.instance.getContacts();
      }
    } catch (e) {
      print('Erreur lors du chargement des contacts: $e');
      _contacts = [];
    }
  }

  Future<void> _loadCallLogs() async {
    try {
      _callLogs = await DatabaseHelper.instance.getCallLogs();
      print('Journaux d\'appels chargés: ${_callLogs.length}');
    } catch (e) {
      print('Erreur lors du chargement des journaux d\'appels: $e');
      _callLogs = [];
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _profileImagePath = prefs.getString('profileImagePath');
  }

  Future<void> addCallLog(CallLog callLog) async {
    try {
      await DatabaseHelper.instance.insertCallLog(callLog);
      await _loadCallLogs();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout d\'un journal d\'appel: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    try {
      await DatabaseHelper.instance.insertContact(contact);
      await _loadContacts();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout d\'un contact: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeCallLog(int index) async {
    try {
      await DatabaseHelper.instance.deleteCallLog(_callLogs[index].id!);
      _callLogs.removeAt(index);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression d\'un journal d\'appel: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  String getContactName(String phoneNumber) {
    final contact = _contacts.firstWhere(
      (contact) => contact.phoneNumber == phoneNumber,
      orElse: () => Contact(name: 'Unknown', phoneNumber: phoneNumber),
    );
    return contact.name;
  }

  @override
  void dispose() {
    _voipService.dispose();
    _callDurationTimer?.cancel();
    super.dispose();
  }
}
