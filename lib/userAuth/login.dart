import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradely/LessonsDetail.dart';
import 'register.dart';
import '../main.dart';
import '../shared/loading.dart';
import '../shared/defaultWidgets.dart';
import 'resetPassword.dart';
import 'package:easy_localization/easy_localization.dart';

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
String _errorMessage = "";

class _LoginScreenState extends State<LoginScreen> {
  signInUser() async {
    FocusScope.of(context).unfocus();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _errorMessage = "This account doesn't exist.";
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _errorMessage = "Wrong password.";
        });
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
        title: Text("Einloggen".tr()),
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
                        decoration: inputDec("Deine Email".tr())),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: _passwordController,
                        textAlign: TextAlign.left,
                        obscureText: true,
                        decoration: inputDec("Dein Passwort".tr())),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _email = _emailController.text;
                          _password = _passwordController.text;
                          isLoading = true;
                        });
                        signInUser();
                      },
                      child: Text("Einloggen")),
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
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text("Hast du noch kein Account?".tr())),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPW()),
                        );
                      },
                      child: Text("Passwort vergessen?".tr())),
                  Spacer(
                    flex: 3,
                  ),
                ],
              ),
            ),
    );
  }
}
