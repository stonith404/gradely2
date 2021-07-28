import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/GRADELY_OLD/data.dart';
import 'package:gradely/GRADELY_OLD/shared/defaultWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:flutter/services.dart';
import 'package:gradely/GRADELY_OLD/userAuth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String _password = "";

var user = FirebaseAuth.instance.currentUser;

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    changeEmailController.text = user.email;
    changeDisplayName.text = auth.currentUser.displayName ?? "";
    passwordPlaceholder.text = "1234567891011";
  }

  changeEmail(_email) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("password".tr()),
            content: Container(
              height: 150,
              child: Column(
                children: [
                  Text("enter_password_save_changes".tr()),
                  SizedBox(height: 10),
                  TextField(
                      controller: passwordController,
                      textAlign: TextAlign.left,
                      obscureText: true,
                      decoration: inputDec("Dein Passwort".tr())),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("ok"),
                onPressed: () async {
                  _password = passwordController.text;
                  var authResult = await user.reauthenticateWithCredential(
                    EmailAuthProvider.credential(
                      email: user.email,
                      password: _password,
                    ),
                  );
                  Navigator.of(context).pop();
                  try {
                    authResult.user.updateEmail(_email);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeWrapper()),
                    );
                  } on FirebaseAuthException catch (e) {}
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        shape: defaultRoundedCorners(),
        actions: [
          IconButton(
              icon: Icon(
                FontAwesome5Solid.sign_out_alt,
                size: 20,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeWrapper()),
                );
              })
        ],
        title: Text("account".tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: changeDisplayName,
                  textAlign: TextAlign.left,
                  decoration: inputDec("yourName".tr())),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: changeEmailController,
                  textAlign: TextAlign.left,
                  decoration: inputDec("email".tr())),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text("change password".tr()),
                            content: Container(
                              height: 140,
                              child: Column(
                                children: [
                                  Text("userInfoRP1".tr()),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                      style: elev(),
                                      onPressed: () {
                                        FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                                email: user.email);

                                        Navigator.of(context).pop();
                                      },
                                      child: Text("send".tr()))
                                ],
                              ),
                            ));
                      });
                },
                child: TextField(
                    enabled: false,
                    obscureText: true,
                    controller: passwordPlaceholder,
                    textAlign: TextAlign.left,
                    decoration: inputDec("password".tr())),
              ),
            ),
            ElevatedButton(
                style: elev(),
                onPressed: () {
                  auth.currentUser.updateDisplayName(changeDisplayName.text);
                  if (changeEmailController.text != auth.currentUser.email) {
                    changeEmail(changeEmailController.text);
                  } else {
                    gradelyDialog(
                        context: context,
                        title: "success".tr(),
                        text: 'nameUpdated'.tr());
                  }
                },
                child: Text("save").tr()),
            Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("userinfoD1".tr()),
                            content: Container(
                              height: 150,
                              child: Column(
                                children: [
                                  Text("userinfoD2".tr()),
                                  SizedBox(height: 10),
                                  TextField(
                                      controller: passwordController,
                                      textAlign: TextAlign.left,
                                      obscureText: true,
                                      decoration:
                                          inputDec("Dein Passwort".tr())),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text("delete".tr()),
                                onPressed: () async {
                                  _password = passwordController.text;
                                  var authResult =
                                      await user.reauthenticateWithCredential(
                                    EmailAuthProvider.credential(
                                      email: user.email,
                                      password: _password,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                  try {
                                    FirebaseFirestore.instance
                                        .collection('userData')
                                        .doc(auth.currentUser.uid)
                                        .delete();
                                    authResult.user.delete();

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()),
                                    );
                                  } on FirebaseAuthException catch (e) {}
                                },
                              ),
                            ],
                          );
                        });
                  },
                  child: Text(
                    "delete_Account".tr(),
                    style: TextStyle(color: Colors.red),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
