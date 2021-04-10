import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';
import '../main.dart';
import '../shared/loading.dart';
import '../shared/defaultWidgets.dart';
import 'login.dart';

class ResetPW extends StatefulWidget {
  @override
  _ResetPWState createState() => _ResetPWState();
}

TextEditingController _emailController = new TextEditingController();

FirebaseAuth auth = FirebaseAuth.instance;

bool isLoading = false;
String _email = "";
String _password = "";

class _ResetPWState extends State<ResetPW> {
  sendPasswordResetEmail(String _email) async {
    var userCredential = await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Passwort vergessen"),
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
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _email = _emailController.text;

                          isLoading = true;
                        });
                       sendPasswordResetEmail(_email);
                      },
                      child: Text("Link anfordern")),
                  Spacer(flex: 1),
                  TextButton(
                      onPressed: (){
                        Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );},
                      
                      child: Text("zurück")),
                  Spacer(
                    flex: 3,
                  ),
                ],
              ),
            ),
    );
  }
}
