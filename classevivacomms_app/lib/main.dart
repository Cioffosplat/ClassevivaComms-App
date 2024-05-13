import 'package:flutter/material.dart';
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
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    String url = 'http://192.168.1.177/projects/ClassevivaComms/Fat3/login';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Aggiungi qui la logica per aprire il profilo utente
            },
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
        'http://192.168.1.177/projects/ClassevivaComms/Fat3/noticeboard';
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
          });
        }
      } else {
        print('Errore durante la richiesta delle comunicazioni: ${response}');
      }
    } catch (e) {
      print('Errore durante la richiesta delle comunicazioni: $e');
      print('Response: ${e}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comunicazioni'),
      ),
      body: UserData.getUserData() == null
          ? Center(
              child: Text('Effettua il login per accedere alle comunicazioni'),
            )
          : _communications.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Titolo')),
                      DataColumn(label: Text('Categoria')),
                      DataColumn(label: Text('Valido Da')),
                      DataColumn(label: Text('Valido A')),
                    ],
                    rows: _communications
                        .map<DataRow>((communication) => DataRow(
                              cells: [
                                DataCell(
                                    Text(communication['cntTitle'] ?? '')),
                                DataCell(Text(
                                    communication['cntCategory'] ?? '')),
                                DataCell(
                                    Text(communication['cntValidFrom'] ?? '')),
                                DataCell(
                                    Text(communication['cntValidTo'] ?? '')),
                              ],
                            ))
                        .toList(),
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
      child: Text('Favorites Page'),
    );
  }
}

class UserData {
  final String ident;
  final String firstName;
  final String lastName;
  final String token;
  final int numericIdent;

  UserData({
    required this.ident,
    required this.firstName,
    required this.lastName,
    required this.token,
  }) : numericIdent = int.parse(ident.replaceAll(RegExp(r'[^0-9]'), ''));

  static UserData? _userData;

  static void setUserData(UserData userData) {
    _userData = userData;
  }

  static UserData? getUserData() {
    return _userData;
  }
}
