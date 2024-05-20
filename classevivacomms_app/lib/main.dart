import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.ubuntuCondensedTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    String url = 'http://192.168.1.187/projects/ClassevivaComms/Fat3/login';
    Map<String, String> data = {
      'username': usernameController.text,
      'password': passwordController.text,
    };

    try {
      var response = await http.post(Uri.parse(url), body: data);
      if (response.statusCode == 200) {
        var loginData = jsonDecode(response.body);
        UserData userData = UserData(
          ident: loginData['ident'],
          firstName: loginData['firstName'],
          lastName: loginData['lastName'],
          token: loginData['token'],
        );
        UserData.setUserData(userData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(userData: userData),
          ),
        );
      } else {
        print('Errore durante il login: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il login')),
        );
      }
    } catch (e) {
      print('Errore durante la richiesta di login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final UserData userData;

  const MainScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    FavoritesPage(),
    CommunicationPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showUserProfile(BuildContext context) async {
    String url = 'http://192.168.1.187/projects/ClassevivaComms/Fat3/card';
    String idWithoutChars =
        UserData.getUserData()!.ident.replaceAll(RegExp(r'[^0-9]'), '');
    Map<String, String> data = {
      'id': idWithoutChars,
      'token': UserData.getUserData()!.token,
    };

    try {
      var response = await http.post(Uri.parse(url), body: data);
      if (response.statusCode == 200) {
        var userProfileData = jsonDecode(response.body)['card'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserProfilePage(userProfileData: userProfileData),
          ),
        );
      } else {
        print(
            'Errore durante la richiesta dei dati utente: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Errore durante la richiesta dei dati utente')),
        );
      }
    } catch (e) {
      print('Errore durante la richiesta dei dati utente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante la richiesta dei dati utente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classeviva Comms'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => _showUserProfile(context),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Preferiti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Comunicazioni',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class UserProfilePage extends StatelessWidget {
  final Map<String, dynamic> userProfileData;

  UserProfilePage({required this.userProfileData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilo Utente'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Nome: ${userProfileData['firstName']} ${userProfileData['lastName']}'),
            Text('Ident: ${userProfileData['ident']}'),
            Text('Tipo Utente: ${userProfileData['usrType']}'),
            Text('ID Utente: ${userProfileData['usrId']}'),
            Text('Codice Fiscale: ${userProfileData['fiscalCode']}'),
            Text('Data di Nascita: ${userProfileData['birthDate']}'),
            Text('Codice Scuola: ${userProfileData['schCode']}'),
            Text(
                'Nome Scuola: ${userProfileData['schName']} ${userProfileData['schDedication']}'),
            Text('Città Scuola: ${userProfileData['schCity']}'),
            Text('Provincia Scuola: ${userProfileData['schProv']}'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    UserData? userData = UserData.getUserData();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Home',
            style: GoogleFonts.ubuntuCondensed(
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Text('Benvenuto, ${userData?.firstName} ${userData?.lastName}!'),
          Text('Ident: ${userData?.ident}'),
          Text('Token: ${userData?.token}'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Aggiungi qui la logica per l'azione del pulsante
            },
            child: Text('Azione'),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Preferiti',
            style: GoogleFonts.ubuntuCondensed(
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Text('Favorites Page'),
        ],
      ),
    );
  }
}

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({Key? key}) : super(key: key);

  @override
  _CommunicationPageState createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  List<dynamic> _communications = [];

  @override
  void initState() {
    super.initState();
    if (UserData.getUserData() != null) {
      _fetchCommunications();
    }
  }

  Future<void> _fetchCommunications() async {
    String url =
        'http://192.168.1.187/projects/ClassevivaComms/Fat3/noticeboard';
    String idWithoutChars =
        UserData.getUserData()!.ident.replaceAll(RegExp(r'[^0-9]'), '');
    Map<String, String> data = {
      'id': idWithoutChars,
      'token': UserData.getUserData()!.token,
    };

    try {
      var response = await http.post(Uri.parse(url), body: data);
      if (response.statusCode == 200) {
        var commsData = jsonDecode(response.body);
        if (commsData != null && commsData['items'] != null) {
          setState(() {
            _communications = commsData['items'];
            _communications.sort((a, b) {
              DateTime dateA = DateTime.parse(a['pubDT']);
              DateTime dateB = DateTime.parse(b['pubDT']);
              return dateB.compareTo(dateA); // Ordine decrescente
            });
          });
        }
      } else {
        print(
            'Errore durante la richiesta delle comunicazioni: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la richiesta delle comunicazioni: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Errore durante la richiesta delle comunicazioni')),
      );
    }
  }

  void _showCommunicationDetails(BuildContext context, dynamic communication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(communication['cntTitle'] ?? ''),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Valid From: ${communication['cntValidFrom'] ?? ''}'),
                Text('Category: ${communication['cntCategory'] ?? ''}'),
                Text('Evento ID: ${communication['evento_id'] ?? ''}'),
                Text('Attachments:'),
                ...?communication['attachments']?.map<Widget>((attachment) {
                  return ListTile(
                    title: Text(attachment['fileName']),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserData.getUserData() == null
          ? Center(
              child: Text('Effettua il login per accedere alle comunicazioni'),
            )
          : _communications.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Text(
                      'Comunicazioni',
                      style: GoogleFonts.ubuntuCondensed(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _communications.length,
                        itemBuilder: (BuildContext context, int index) {
                          final communication = _communications[index];
                          return ListTile(
                            title: Text(communication['cntTitle'] ?? ''),
                            onTap: () {
                              _showCommunicationDetails(context, communication);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class UserData {
  final String ident;
  final String firstName;
  final String lastName;
  final String token;

  UserData({
    required this.ident,
    required this.firstName,
    required this.lastName,
    required this.token,
  });

  static UserData? _userData;

  static UserData? getUserData() {
    return _userData;
  }

  static void setUserData(UserData userData) {
    _userData = userData;
  }
}
