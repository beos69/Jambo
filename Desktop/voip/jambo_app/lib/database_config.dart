import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> configureDatabaseFactory() async {
  if (kIsWeb) {
    // Pour le web, nous n'avons pas besoin de configurer databaseFactory
    // car sqflite n'est pas supporté sur le web.
    // Vous devrez utiliser une alternative pour le stockage sur le web,
    // comme IndexedDB ou localStorage.
    print('Running on web, skipping database configuration');
  } else {
    // Configuration pour les autres plateformes
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}