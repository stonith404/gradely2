import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradely/GRADELY_OLD/main.dart' show OLDMaterialWrapper;
import 'package:gradely/main.dart';

import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:gradely/shared/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';

import 'resetPassword.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

TextEditingController _emailController = new TextEditingController();
TextEditingController _passwordController = new TextEditingController();
FirebaseAuth auth = FirebaseAuth.instance;

String _errorMessage = "";

class _LoginScreenState extends State<LoginScreen> {
  signInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FocusScope.of(context).unfocus();
    Future result = account.createSession(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    result.then((response) {
      setState(() {
        isLoading = false;
      });

      prefs.remove("newGradely");
      prefs.setBool("signedIn", true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeWrapper()),
      );

      _passwordController.text = "";
      print(response);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      gradelyDialog(context: context, title: "error".tr(), text: error.message);
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
          leading: Container(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Image.asset(
            'assets/images/iconT.png',
            height: 60,
          ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "welcome_back".tr(),
                              style:
                                  TextStyle(fontSize: 40, color: Colors.white),
                            ),
                   
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
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF554dd1), // background
                        ),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          signInUser();
                        },
                        child: Text("sign_in".tr())),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OLDMaterialWrapper()),
                          );
                        },
                        child: Text(
                            "❗️" + "gradely_migration_registred_before".tr(),
                            style: TextStyle(color: Colors.white))),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text("question_no_account".tr(),
                            style: TextStyle(color: Colors.white))),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ResetPW()),
                          );
                        },
                        child: Text(
                          "question_forgot_password".tr(),
                          style: TextStyle(color: Colors.white),
                        )),
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

InputDecoration inputDecAuth(_label) {
  return InputDecoration(
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        borderSide: BorderSide.none),
    filled: true,
    labelText: _label,
    fillColor: Color(0xFF554dd1),
    labelStyle: TextStyle(fontSize: 17.0, height: 0.8, color: Colors.white),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide.none,
    ),
  );
}
