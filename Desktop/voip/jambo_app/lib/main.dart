import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'models/contact.dart';
import 'models/call_log.dart';
import 'providers/app_state.dart';
import 'database_config.dart';
import 'utils/app_theme.dart';
import 'models/call_state.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'utils/permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Ajouté pour Timer
import 'package:flutter/foundation.dart'; // Ajouté pour kIsWeb
import 'services/notification_service.dart'; // Ajoutez cette ligne
import 'package:awesome_notifications/awesome_notifications.dart'; // Ajoutez cette ligne

Future<void> requestPermissions() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.notification, // Ajoutez cette permission
  ].request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    sqfliteFfiInit();
    await configureDatabaseFactory();
  }

  await requestPermissions();
  await requestAudioPermissions();
  await NotificationService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const JamboApp(),
    ),
  );
}

class JamboApp extends StatelessWidget {
  const JamboApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Jambo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: appState.isLoaded ? const HomePage() : const LoadingScreen(),
        );
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Chargement des données...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  String phoneNumber = '';
  final List<int> _selectedCallLogs = [];

  bool isCallInProgress = false; // Ajouté
  bool isSpeakerOn = false; // Ajouté
  bool isMuted = false; // Ajouté
  String callDuration = '00:00'; // Ajouté
  Timer? _timer; // Ajouté

  @override
  void initState() {
    super.initState();
  }

  void _showConnectionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Erreur de connexion'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            // Ne rien faire ici car nous n'utilisons plus WebSocket
          },
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addNumber(String number) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isInCall) {
      setState(() {
        phoneNumber += number;
      });
    }
  }

  void _deleteNumber() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isInCall && phoneNumber.isNotEmpty) {
      setState(() {
        phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
      });
    }
  }

  Future<void> _makeCall() async {
    if (phoneNumber.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Veuillez entrer un numéro de téléphone',
        backgroundColor: Colors.red,
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.makeCall(phoneNumber);

      Fluttertoast.showToast(
        msg: 'Appel en cours vers $phoneNumber',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  void _startCallTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final parts = callDuration.split(':');
          int minutes = int.parse(parts[0]);
          int seconds = int.parse(parts[1]);

          seconds++;
          if (seconds >= 60) {
            seconds = 0;
            minutes++;
          }

          callDuration =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void endCall() {
    if (isCallInProgress) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.endCall();

      // Ajouter l'appel au journal
      appState.addCallLog(CallLog(
        number: phoneNumber,
        timestamp: DateTime.now(),
        duration: int.parse(callDuration.split(':')[0]) * 60 +
            int.parse(callDuration.split(':')[1]),
        status: 'completed',
        type: 'outgoing',
      ));

      setState(() {
        isCallInProgress = false;
        isSpeakerOn = false;
        isMuted = false;
      });

      _timer?.cancel();
      callDuration = '00:00';
    }
  }

  Widget _buildCallScreen() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final duration = appState.callDuration;
        final formattedDuration =
            '${(duration ~/ 60).toString().padLeft(2, '0')}:${(duration % 60).toString().padLeft(2, '0')}';

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Appel en cours',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formattedDuration,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCallButton(
                        Icons.volume_up,
                        'HP',
                        appState.isSpeakerOn,
                        () => appState.toggleSpeaker(),
                      ),
                      _buildCallButton(
                        Icons.mic_off,
                        'Muet',
                        appState.isMuted,
                        () => appState.toggleMute(),
                      ),
                      _buildCallButton(
                        Icons.dialpad,
                        'Clavier',
                        false,
                        () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => appState.endCall(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.call_end,
                        color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCallButton(
      IconData icon, String label, bool isActive, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: isActive ? Colors.blue : Colors.grey[600],
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDialPad() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          phoneNumber,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.backspace,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: _deleteNumber,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9) return _buildDialButton('*');
                    if (index == 10) return _buildDialButton('0');
                    if (index == 11) return _buildDialButton('#');
                    return _buildDialButton('${index + 1}');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: appState.isInCall ? null : _makeCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    elevation: 5,
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 36),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialButton(String number) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _addNumber(number),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentsScreen() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.callLogs.isEmpty) {
          return const Center(child: Text('Aucun appel récent'));
        }
        return Scaffold(
          body: ListView.builder(
            itemCount: appState.callLogs.length,
            itemBuilder: (context, index) {
              final call = appState.callLogs[index];
              final isSelected = _selectedCallLogs.contains(index);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                child: ListTile(
                  leading: const Icon(Icons.call),
                  title: Text(call.number),
                  subtitle: Text(
                      '${call.timestamp.toString().split('.')[0]} - ${call.duration} seconds'),
                  trailing: const Icon(Icons.call_made),
                  onLongPress: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCallLogs.remove(index);
                      } else {
                        _selectedCallLogs.add(index);
                      }
                    });
                  },
                  onTap: () {
                    if (_selectedCallLogs.isNotEmpty) {
                      setState(() {
                        if (isSelected) {
                          _selectedCallLogs.remove(index);
                        } else {
                          _selectedCallLogs.add(index);
                        }
                      });
                    }
                  },
                ),
              );
            },
          ),
          floatingActionButton: _selectedCallLogs.isNotEmpty
              ? FloatingActionButton(
                  child: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, appState);
                  },
                )
              : null,
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer les appels sélectionnés'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer ces appels de l\'historique ?'),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Supprimer'),
              onPressed: () {
                _selectedCallLogs.sort((a, b) => b.compareTo(a));
                for (var index in _selectedCallLogs) {
                  appState.removeCallLog(index);
                }
                setState(() {
                  _selectedCallLogs.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactsScreen() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: appState.contacts.isEmpty
              ? const Center(child: Text('Aucun contact'))
              : ListView.builder(
                  itemCount: appState.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = appState.contacts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(contact.name[0])),
                        title: Text(contact.name),
                        subtitle: Text(contact.phoneNumber),
                        trailing: IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {
                            setState(() {
                              phoneNumber = contact.phoneNumber;
                              _selectedIndex = 1;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _showAddContactDialog(context, appState),
          ),
        );
      },
    );
  }

  void _showAddContactDialog(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String surname = '';
    String phone = '';
    String email = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un contact'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: (value) =>
                        value!.isEmpty ? 'Champ requis' : null,
                    onSaved: (value) => name = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) =>
                        value!.isEmpty ? 'Champ requis' : null,
                    onSaved: (value) => surname = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    validator: (value) =>
                        value!.isEmpty ? 'Champ requis' : null,
                    onSaved: (value) => phone = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onSaved: (value) => email = value ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Ajouter'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  appState.addContact(Contact(
                    name: '$name $surname',
                    phoneNumber: phone,
                    email: email,
                  ));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileScreen() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: appState.profileImagePath != null
                    ? FileImage(File(appState.profileImagePath!))
                    : null,
                child: appState.profileImagePath == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: const Text('Votre nom'),
              trailing: IconButton(
                icon: const Icon(Icons.add_a_photo),
                onPressed: () => _changeProfilePicture(appState),
              ),
            ),
            const Divider(),
            // Options du menu
            _buildMenuItem(Icons.key, 'Compte',
                'Notifications de sécurité, se déconnecter'),
            _buildMenuItem(Icons.lock, 'Confidentialité',
                'Bloquer des contacts, messages éphémères'),
            _buildMenuItem(Icons.chat_bubble_outline, 'Discussions',
                'Thèmes, fonds d\'écran, historique des discussions'),
            _buildMenuItem(Icons.notifications, 'Notifications',
                'Sonneries des messages, groupes et appels'),
            _buildMenuItem(Icons.storage, 'Stockage et données',
                'Utilisation réseau, téléchargement auto.'),
            _buildMenuItem(Icons.language, 'Langue de l\'application',
                'Français (langue de l\'appareil)'),
            _buildMenuItem(Icons.help_outline, 'Aide',
                'Centre d\'aide, contactez-nous, Politique de confidentialité'),
            _buildMenuItem(Icons.person_add, 'Inviter un contact', ''),
            // Mode sombre (switch)
            SwitchListTile(
              title: const Text('Mode sombre'),
              value: appState.isDarkMode,
              onChanged: (value) {
                appState.toggleDarkMode();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeProfilePicture(AppState appState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      appState.setProfileImage(image.path);
    }
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Action à effectuer lorsqu'un élément du menu est tapoté
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: PageTransitionSwitcher(
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: appState.isInCall ? _buildCallScreen() : _buildBody(),
          ),
          bottomNavigationBar:
              !appState.isInCall ? _buildBottomNavigationBar() : null,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Card(
      margin: EdgeInsets.zero,
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Récents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dialpad),
            label: 'Clavier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildRecentsScreen();
      case 1:
        return isCallInProgress ? _buildCallScreen() : _buildDialPad();
      case 2:
        return _buildContactsScreen();
      case 3:
        return _buildProfileScreen();
      default:
        return _buildDialPad();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
