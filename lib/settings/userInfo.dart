import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/data.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/main.dart';
import 'package:flutter/services.dart';
import 'package:gradely/auth/login.dart';

String _password = "";

var fuser = FirebaseAuth.instance.currentUser;

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  @override
  void initState() {
    super.initState();

    changeEmailController.text = user.email;
    changeDisplayName.text = user.name ?? "";
    passwordPlaceholder.text = "1234567891011";
  }

  changeEmail(_email) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("userinfoP1".tr()),
            content: Container(
              height: 150,
              child: Column(
                children: [
                  Text("userinfoP2".tr()),
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

                  Navigator.of(context).pop();
                  try {
                    await account.updateEmail(
                      email: _email,
                      password: _password,
                    );
                    getUserInfo();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeWrapper()),
                    );
                  } on FirebaseAuthException catch (_) {}

                  HapticFeedback.lightImpact();
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
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(
                FontAwesome5Solid.sign_out_alt,
                size: 20,
                color: primaryColor,
              ),
              onPressed: () async {
                Future result = account.getSession(
                  sessionId: 'current',
                );

                await result.then((response) {
                  response = jsonDecode(response.toString());

                  account.deleteSession(sessionId: response["\$id"]);
                });

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeWrapper()),
                );
              })
        ],
        title: Text("account".tr(), style: appBarTextTheme),
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
                  decoration: inputDec("userinfo1".tr())),
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
                                        Future result = account.createRecovery(
                                          email: "login@eliasschneider.com",
                                          url:
                                              'https://aw.cloud.eliasschneider.com',
                                        );
                                        result.then((response) {
                                          print(response);
                                        }).catchError((error) {
                                          print(error.response);
                                        });

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
                  account.updateName(name: changeDisplayName.text);
                  if (changeEmailController.text != user.email) {
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
                        builder: (BuildContext contextP) {
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
                                    Navigator.of(contextP).pop();
                                    if (await reAuthenticate(
                                        email: user.email,
                                        password: passwordController.text)) {
                                      await database.deleteDocument(
                                          collectionId: collectionUser,
                                          documentId: user.dbID);

                                      await account.delete();

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()),
                                      );

                                      HapticFeedback.lightImpact();
                                    } else {
                                      gradelyDialog(
                                          context: context,
                                          title: "error".tr(),
                                          text: "wrongPassword".tr());
                                    }
                                  }),
                            ],
                          );
                        });
                  },
                  child: Text(
                    "userinfoP3".tr(),
                    style: TextStyle(color: Colors.red),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
