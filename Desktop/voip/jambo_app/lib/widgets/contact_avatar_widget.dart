import 'package:flutter/material.dart';
import 'dart:io';
import '../models/contact.dart';

class ContactAvatarWidget extends StatelessWidget {
  final Contact contact;
  final double size;
  final VoidCallback? onTap;

  const ContactAvatarWidget({
    Key? key,
    required this.contact,
    this.size = 40,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: _getAvatarColor(contact.name),
        backgroundImage: contact.imageUrl != null
            ? FileImage(File(contact.imageUrl!))
            : null,
        child: contact.imageUrl == null
            ? Text(
                _getInitials(contact.name),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _getAvatarColor(String name) {
    final List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.orange,
      Colors.deepOrange,
    ];

    final int hashCode = name.hashCode;
    return colors[hashCode.abs() % colors.length];
  }
}
