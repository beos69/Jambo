import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';
import '../models/call_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<dynamic> get database async {
    if (!kIsWeb) {
      if (_database != null) return _database!;
      _database = await _initDB('jambo.db');
      return _database!;
    }
    return null;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2, // Incrémenté pour la nouvelle structure
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE call_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        duration INTEGER NOT NULL,
        status TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajouter les nouvelles colonnes à call_logs si elles n'existent pas
      await db.execute(
          'ALTER TABLE call_logs ADD COLUMN status TEXT DEFAULT "unknown"');
      await db.execute(
          'ALTER TABLE call_logs ADD COLUMN type TEXT DEFAULT "unknown"');
    }
  }

  Future<int> insertContact(Contact contact) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> contacts = prefs.getStringList('contacts') ?? [];
      contacts.add(jsonEncode(contact.toMap()));
      await prefs.setStringList('contacts', contacts);
      return contacts.length;
    } else {
      final db = await database;
      return await db.insert('contacts', contact.toMap());
    }
  }

  Future<List<Contact>> getContacts() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> contacts = prefs.getStringList('contacts') ?? [];
      return contacts
          .map((contactJson) => Contact.fromMap(jsonDecode(contactJson)))
          .toList();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('contacts');
      return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
    }
  }

  Future<int> insertCallLog(CallLog callLog) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> callLogs = prefs.getStringList('call_logs') ?? [];
      callLogs.add(jsonEncode(callLog.toMap()));
      await prefs.setStringList('call_logs', callLogs);
      return callLogs.length;
    } else {
      final db = await database;
      return await db.insert('call_logs', callLog.toMap());
    }
  }

  Future<List<CallLog>> getCallLogs() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> callLogs = prefs.getStringList('call_logs') ?? [];
      return callLogs
          .map((logJson) => CallLog.fromMap(jsonDecode(logJson)))
          .toList();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query('call_logs', orderBy: 'timestamp DESC');
      return List.generate(maps.length, (i) => CallLog.fromMap(maps[i]));
    }
  }

  Future<int> deleteCallLog(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> callLogs = prefs.getStringList('call_logs') ?? [];
      callLogs.removeWhere((logJson) {
        final log = CallLog.fromMap(jsonDecode(logJson));
        return log.id == id;
      });
      await prefs.setStringList('call_logs', callLogs);
      return 1;
    } else {
      final db = await database;
      return await db.delete(
        'call_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<int> deleteContact(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> contacts = prefs.getStringList('contacts') ?? [];
      contacts.removeWhere((contactJson) {
        final contact = Contact.fromMap(jsonDecode(contactJson));
        return contact.id == id;
      });
      await prefs.setStringList('contacts', contacts);
      return 1;
    } else {
      final db = await database;
      return await db.delete(
        'contacts',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> clearAllData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('contacts');
      await prefs.remove('call_logs');
    } else {
      final db = await database;
      await db.delete('contacts');
      await db.delete('call_logs');
    }
  }

  Future close() async {
    final db = await database;
    if (!kIsWeb) {
      db?.close();
    }
  }
}
