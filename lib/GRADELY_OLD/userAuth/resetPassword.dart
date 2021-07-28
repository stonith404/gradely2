import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradely/GRADELY_OLD//main.dart';
import 'package:gradely/GRADELY_OLD//shared/loading.dart';
import 'package:gradely/GRADELY_OLD/userAuth/login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
    var userCredential =
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
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
                              "Reset".tr(),
                              style:
                                  TextStyle(fontSize: 40, color: Colors.white),
                            ),
                            Text(
                              "Password".tr(),
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
                      flex: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecAuth("Deine Email".tr()),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF554dd1), // background
                        ),
                        onPressed: () {
                          _email = _emailController.text;

                          sendPasswordResetEmail(_email);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(FontAwesome5Solid.check_circle),
                                      Spacer(flex: 1),
                                      Text("contactSuccess1".tr()),
                                      Spacer(flex: 10)
                                    ],
                                  ),
                                  content: Text("pwResetSuccess1".tr()),
                                  actions: <Widget>[
                                    FlatButton(
                                      color: primaryColor,
                                      child: Text("ok"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Text("Link anfordern".tr())),
                    Spacer(flex: 1),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text("zurück".tr(),
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