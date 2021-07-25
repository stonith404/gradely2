import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradely/auth/login.dart';
import 'package:gradely/introScreen.dart';
import 'package:gradely/shared/VARIABLES.dart';
import '../main.dart';
import '../shared/defaultWidgets.dart';
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

String _errorMessage = "";

class _RegisterScreenState extends State<RegisterScreen> {
  createUser() async {
    FocusScope.of(context).unfocus();

    Future resultCreateAccount = account.create(
      email: _emailController.text,
      password: _passwordController.text,
    );

    resultCreateAccount.then((response) async {
      await account.createSession(
        email: _emailController.text,
        password: _passwordController.text,
      );
      response = jsonDecode(response.toString());

      Future resultCreateDB =
          database.createDocument(collectionId: collectionUser, data: {
        "uid": response["\$id"],
        "gradelyPlus": false,
        "gradeType": "av",
        "choosenSemester": "noSemesterChoosed"
      });

      resultCreateDB.then((response) {
        print(response);
      }).catchError((error) {
        print(error);
        print(error.response);
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IntroScreen()),
      );
    }).catchError((error) {
      print(error);
      print(error.response);

      gradelyDialog(context: context, title: "error".tr(), text: error.message);
    });

    setState(() {
      isLoading = false;
    });
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
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Image.asset(
            'assets/images/iconT.png',
            height: 60,
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
                    decoration: inputDecAuth("Deine Email".tr())),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    decoration: inputDecAuth("Dein Passwort".tr())),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF554dd1), // background
                  ),
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    createUser();

                    HapticFeedback.lightImpact();
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
