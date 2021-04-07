import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';
import '../main.dart';
import '../shared/loading.dart';
import '../shared/defaultWidgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

TextEditingController _emailController = new TextEditingController();
TextEditingController _passwordController = new TextEditingController();
FirebaseAuth auth = FirebaseAuth.instance;

bool isLoading = false;
String _email = "";
String _password = "";

class _LoginScreenState extends State<LoginScreen> {
  createUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einloggen"),
      ),
      body: isLoading
          ? LoadingScreen()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Spacer(
                  flex: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "👋",
                      style: TextStyle(fontSize: 50),
                    ),
                    Image.asset(
                      'assets/iconT.png',
                      height: 170,
                    ),
                  ],
                ),
                Spacer(
                  flex: 1,
                ),
                TextField(
                    controller: _emailController,
                    textAlign: TextAlign.left,
                    decoration: inputDec("Deine Email")),
                TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    decoration: inputDec("Dein Passwort")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _email = _emailController.text;
                        _password = _passwordController.text;
                        isLoading = true;
                      });
                      createUser();
                    },
                    child: Text("Einloggen")),
                Spacer(
                  flex: 4,
                ),
              ],
            ),
    );
  }
}
