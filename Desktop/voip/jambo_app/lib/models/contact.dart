//contact.dart

class Contact {
  final int? id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? imageUrl;

  Contact(
      {this.id,
      required this.name,
      required this.phoneNumber,
      this.email,
      this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'imageUrl': imageUrl,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      imageUrl: map['imageUrl'],
    );
  }
}
