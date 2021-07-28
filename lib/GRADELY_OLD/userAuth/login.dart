import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:gradely/GRADELY_OLD//shared/loading.dart';
import 'package:gradely/GRADELY_OLD//shared/defaultWidgets.dart';
import 'package:gradely/GRADELY_OLD/userAuth/resetPassword.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gradely/screens/auth/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FocusScope.of(context).unfocus();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      setState(() {
        isLoading = false;
      });
      prefs.setBool("newGradely", false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeWrapper()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        gradelyDialog(
            context: context, title: "error".tr(), text: "userNotFound".tr());
      } else if (e.code == 'wrong-password') {
        gradelyDialog(
            context: context, title: "error".tr(), text: "wrongPassword".tr());
      }
      setState(() {
        isLoading = false;
      });
    }
    _passwordController.text = "";
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance
        .addPostFrameCallback((_) => gradelyOLDinfo(context));
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
                              "Welcome".tr(),
                              style:
                                  TextStyle(fontSize: 40, color: Colors.white),
                            ),
                            Text(
                              "Back".tr(),
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
                          decoration: InputDecAuth("your_email".tr())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: _passwordController,
                          textAlign: TextAlign.left,
                          obscureText: true,
                          decoration: InputDecAuth("your_password".tr())),
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

InputDecoration InputDecAuth(_label) {
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
