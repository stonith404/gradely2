import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';
import '../main.dart';
import '../shared/loading.dart';
import '../shared/defaultWidgets.dart';
import 'login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

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
        appBar: AppBar(
          title: Text("Passwort vergessen?".tr()),
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
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _email = _emailController.text;

                            isLoading = true;
                          });
                          sendPasswordResetEmail(_email);
                        },
                        child: Text("Link anfordern".tr())),
                    Spacer(flex: 1),
                    TextButton(
                        onPressed: () {
                           HapticFeedback.lightImpact();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text("zurück".tr())),
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
