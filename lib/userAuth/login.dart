import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';
import '../main.dart';
import '../shared/loading.dart';
import '../shared/defaultWidgets.dart';
import 'resetPassword.dart';

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

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
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
          : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Spacer(
                    flex: 2,
                  ),
                 
                      Image.asset(
                        'assets/iconT.png',
                        height: 170,
                     
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: _emailController,
                        textAlign: TextAlign.left,
                        decoration: inputDec("Deine Email")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: _passwordController,
                        textAlign: TextAlign.left,
                        obscureText: true,
                        decoration: inputDec("Dein Passwort")),
                  ),
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
                      Spacer(flex: 1),
                      TextButton(onPressed: (){ Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );}, child: Text("Hast du noch kein Account?")),
                TextButton(onPressed: (){ Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResetPW()),
              );}, child: Text("PW")),
                  Spacer(
                    flex: 3,
                  ),
                ],
              ),
          ),
    );
  }
}
