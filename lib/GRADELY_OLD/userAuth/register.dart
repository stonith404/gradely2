import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:gradely/GRADELY_OLD/userAuth/login.dart';
import '../shared/defaultWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/GRADELY_OLD/introScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'login.dart';

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
        gradelyDialog(
            context: context, title: "error".tr(), text: "weakPassword".tr());
        setState(() {
          isLoading = false;
        });
      } else if (e.code == 'email-already-in-use') {
        gradelyDialog(
            context: context, title: "error".tr(), text: "emailInUse".tr());
        setState(() {
          isLoading = false;
        });
      } else if (e.code == 'invalid-email') {
        gradelyDialog(
            context: context, title: "error".tr(), text: "invalidEmail".tr());
        setState(() {
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
    _passwordController.text = "";
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
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OLD VERSION OF GRADELY",
                style: TextStyle(fontSize: 15),
              ),
              IconButton(
                  onPressed: () {
                    gradelyOLDinfo(context);
                  },
                  icon: Icon(Icons.info_rounded))
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Spacer(
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create".tr(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      Text(
                        "Account".tr(),
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Spacer(
                flex: 4,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    textAlign: TextAlign.left,
                    decoration: InputDecAuth("Deine Email".tr())),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    decoration: InputDecAuth("Dein Passwort".tr())),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF554dd1), // background
                  ),
                  onPressed: () {
                    setState(() {
                      _email = _emailController.text;
                      _password = _passwordController.text;
                      isLoading = true;
                    });
                    createUser();
                  },
                  child: Text("Registrieren".tr(),
                      style: TextStyle(color: Colors.white))),
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
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text("Hast du schon ein Account?".tr(),
                      style: TextStyle(color: Colors.white))),
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