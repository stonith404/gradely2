import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradely/userAuth/login.dart';
import 'register.dart';
import '../main.dart';
import '../shared/loading.dart';
import '../shared/defaultWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/introScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

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
        MaterialPageRoute(builder: (context) => IntroScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'weak-password') {
        setState(() {
          _errorMessage = "To weak password.";
          isLoading = false;
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _errorMessage = "This email is already in use.";
          isLoading = false;
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          _errorMessage = "Invalid Email.";
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: defaultColor,
          title: Text("Registrieren".tr()),
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
                      'assets/images/iconT.png',
                      height: 170,
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          keyboardType: TextInputType.emailAddress,
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
                        style: elev(),
                        onPressed: () {
                          setState(() {
                            _email = _emailController.text;
                            _password = _passwordController.text;
                            isLoading = true;
                          });
                          createUser();
                        
                          HapticFeedback.lightImpact();
                        },
                        child: Text("Registrieren".tr())),
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
                        child: Text("Hast du schon ein Account?".tr())),
                    Spacer(
                      flex: 3,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
