import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradely/userAuth/login.dart';
import 'register.dart';
import '../main.dart';
import '../shared/loading.dart';
import '../shared/defaultWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/introScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

TextEditingController _emailController = new TextEditingController();
TextEditingController _passwordController = new TextEditingController();
FirebaseAuth auth = FirebaseAuth.instance;

bool isLoading = false;
String _email = "";
String _password = "";
bool _registerSucceded = false;
String _errorMessage = "";

class _RegisterScreenState extends State<RegisterScreen> {
  createUser() async {
    FocusScope.of(context).unfocus();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      FirebaseFirestore.instance
          .collection('userData')
          .doc(auth.currentUser.uid)
          .set({
        'choosenSemester': 'noSemesterChoosed',
        'gradesResult': 'Durchschnitt'
      });
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'weak-password') {
        setState(() {
          _errorMessage = "Dieses Passwort ist zu schwach.";
          isLoading = false;
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _errorMessage = "Diese Email hat schon einen Account.";
          isLoading = false;
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          _errorMessage = "Deine Email ist nicht gültig.";
          isLoading = false;
        });
      }
      setState(() {
        _registerSucceded = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e;
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
        title: Text("Registrieren"),
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
                        style: TextStyle(color: Colors.black),
                        controller: _emailController,
                        textAlign: TextAlign.left,
                        decoration: inputDec("Deine Email")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        style: TextStyle(color: Colors.black),
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IntroScreen()),
                        );
                      },
                      child: Text("Registrieren")),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                  Spacer(flex: 1),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text("Hast du schon ein Account?")),
                  Spacer(
                    flex: 3,
                  ),
                ],
              ),
            ),
    );
  }
}
