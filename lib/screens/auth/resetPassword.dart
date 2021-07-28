import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradely/main.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:gradely/shared/loading.dart';
import 'login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ResetPW extends StatefulWidget {
  @override
  _ResetPWState createState() => _ResetPWState();
}

TextEditingController _emailController = new TextEditingController();

FirebaseAuth auth = FirebaseAuth.instance;

String _email = "";

class _ResetPWState extends State<ResetPW> {
  sendPasswordResetEmail(String _email) async {
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
                              "reset".tr(),
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
                        decoration: inputDecAuth("your_email".tr()),
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
                                      Text("sent".tr()),
                                      Spacer(flex: 10)
                                    ],
                                  ),
                                  content:
                                      Text("password_reset_success_text".tr()),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: elev(),
                                      child: Text("ok"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Text("request_link".tr())),
                    Spacer(flex: 1),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text("back".tr(),
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
