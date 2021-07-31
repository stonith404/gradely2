import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely/screens/auth/introScreen.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gradely/shared/WIDGETS.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

TextEditingController _emailController = new TextEditingController();
TextEditingController _passwordController = new TextEditingController();

String _errorMessage = "";

class _RegisterScreenState extends State<RegisterScreen> {
  createUser() async {
       isLoadingController.add(true);
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
      prefs.setBool("signedIn", true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IntroScreen()),
      );
    }).catchError((error) {
      print(error);
      print(error.response);

      errorSuccessDialog(context: context, error: true, text: error.message);
    });

    isLoadingController.add(false);
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
          title: SvgPicture.asset("assets/images/logo.svg",
              color: primaryColor, height: 30),
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
                        "create".tr(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      Text(
                        "account".tr(),
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
                    decoration: inputDecAuth("your_email".tr())),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    decoration: inputDecAuth("your_password".tr())),
              ),
              gradelyButton(
                onPressed: () async {
               
                  await createUser();
                
                },
                text: "sign_up".tr(),
              ),
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
                  child: Text("question_have_account".tr(),
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
