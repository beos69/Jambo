import 'dart:async';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/contact.dart';
import '../services/database_helper.dart';

class ContactsService {
  final _contactsController = StreamController<List<Contact>>.broadcast();
  Stream<List<Contact>> get contactsStream => _contactsController.stream;

  Future<void> syncContacts() async {
    if (await FlutterContacts.requestPermission()) {
      // Récupérer les contacts du téléphone
      final phoneContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // Convertir les contacts du téléphone en contacts de l'application
      final appContacts = phoneContacts.map((phoneContact) {
        final mainPhone = phoneContact.phones.isNotEmpty
            ? phoneContact.phones.first.number
            : '';

        return Contact(
          name: '${phoneContact.name.first} ${phoneContact.name.last}'.trim(),
          phoneNumber: mainPhone,
          email: phoneContact.emails.isNotEmpty
              ? phoneContact.emails.first.address
              : null,
        );
      }).toList();

      // Sauvegarder les contacts dans la base de données
      final db = DatabaseHelper.instance;
      await db.clearAllData(); // Optionnel : effacer les anciens contacts

      for (var contact in appContacts) {
        await db.insertContact(contact);
      }

      // Notifier les écouteurs
      final updatedContacts = await db.getContacts();
      _contactsController.add(updatedContacts);
    }
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = DatabaseHelper.instance;
    final allContacts = await db.getContacts();

    if (query.isEmpty) return allContacts;

    return allContacts.where((contact) {
      final nameLower = contact.name.toLowerCase();
      final phoneLower = contact.phoneNumber.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) ||
          phoneLower.contains(searchLower);
    }).toList();
  }

  void dispose() {
    _contactsController.close();
  }
}
