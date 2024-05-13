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
    String url = 'http://192.168.101.35/projects/ClassevivaComms/Fat3/login';
    Map<String, String> data = {
      'username': usernameController.text,
      'password': passwordController.text,
    };

    try {
      var response = await http.post(Uri.parse(url), body: data);
      if (response.statusCode == 200) {
        var loginData = jsonDecode(response.body);
        // Gestisci i dati di accesso qui, ad esempio:
        print(loginData);
        // Naviga a una nuova schermata dopo il login con i dati dell'utente
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(loginData: loginData),
          ),
        );
      } else {
        // Gestisci gli errori di login qui
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

class HomePage extends StatelessWidget {
  final dynamic loginData;

  const HomePage({Key? key, required this.loginData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Benvenuto, ${loginData['firstName']} ${loginData['lastName']}!'),
            // Aggiungi qui altri widget per mostrare le informazioni dell'utente
          ],
        ),
      ),
    );
  }
}
