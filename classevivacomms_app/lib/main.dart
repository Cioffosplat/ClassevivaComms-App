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

class MainScreen extends StatelessWidget {
  final UserData userData;

  const MainScreen({Key? key, required this.userData}) : super(key: key);

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Benvenuto, ${userData.firstName} ${userData.lastName}!',
              style: TextStyle(fontSize: 18),
            ),
            Text('Ident: ${userData.numericIdent}'),
            Text('Token: ${userData.token}'),
          ],
        ),
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
        selectedItemColor: Colors.blue,
        selectedIconTheme: IconThemeData(color: Colors.blue),
      ),
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
  }) : numericIdent = int.parse(ident.substring(1, ident.length - 1));

  static UserData? _userData;

  static void setUserData(UserData userData) {
    _userData = userData;
  }

  static UserData? getUserData() {
    return _userData;
  }
}
