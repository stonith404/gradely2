import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely2/screens/auth/sign_in.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/main.dart';
import 'package:flutter/services.dart';

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
    passwordPlaceholder.text = "123456789";
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
                  prefs.setBool("signedIn", false);
                });

                clearVariables();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeWrapper()),
                );
              })
        ],
        title: Text("account".tr(), style: appBarTextTheme),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 70),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: changeDisplayName,
                      textAlign: TextAlign.left,
                      decoration: inputDec(label: "your_name".tr())),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      await account.updateName(name: changeDisplayName.text);
                      errorSuccessDialog(
                          context: context,
                          error: false,
                          text: 'name_updated'.tr());
                    } catch (e) {
                      errorSuccessDialog(
                          context: context,
                          error: true,
                          text: "error_unknown".tr());
                    }
                  },
                  icon: Icon(FontAwesome5Solid.save),
                  color: primaryColor,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: changeEmailController,
                      textAlign: TextAlign.left,
                      decoration: inputDec(label: "email".tr())),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      changeEmail(changeEmailController.text, context);
                    } catch (e) {
                      errorSuccessDialog(
                          context: context,
                          error: true,
                          text: "error_unknown".tr());
                    }
                  },
                  icon: Icon(FontAwesome5Solid.save),
                  color: primaryColor,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("change_password".tr()),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("change_password_text".tr()),
                            SizedBox(height: 20),
                            gradelyButton(
                                onPressed: () {
                                  isLoadingController.add(true);
                                  Future result = account.createRecovery(
                                    email: user.email,
                                    url:
                                        'https://user.gradelyapp.com?mode=passwordReset',
                                  );
                                  result.then((response) {
                                    print(response);
                                  }).catchError((error) {
                                    errorSuccessDialog(
                                        context: context,
                                        error: true,
                                        text: error.message);
                                  });

                                  Navigator.of(context).pop();
                                  isLoadingController.add(false);
                                },
                                text: "send".tr())
                          ],
                        ),
                      );
                    });
              },
              child: TextField(
                  enabled: false,
                  obscureText: true,
                  controller: passwordPlaceholder,
                  textAlign: TextAlign.left,
                  decoration: inputDec(label: "password".tr())),
            ),
            SizedBox(
              height: 20,
            ),
            Spacer(flex: 100),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext contextP) {
                          return AlertDialog(
                            title: Text("delete_account".tr()),
                            content: Container(
                              height: 150,
                              child: Column(
                                children: [
                                  Text("delete_account_text".tr()),
                                  SizedBox(height: 10),
                                  TextField(
                                      controller: passwordController,
                                      textAlign: TextAlign.left,
                                      obscureText: true,
                                      decoration: inputDec(
                                          label: "your_password".tr())),
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
                                      clearVariables();
                                      passwordController.text = "";
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignInPage()),
                                      );
                                      prefs.setBool("signedIn", false);
                                    } else {
                                      errorSuccessDialog(
                                          context: context,
                                          error: true,
                                          text: "error_wrong_password".tr());
                                    }
                                  }),
                            ],
                          );
                        });
                  },
                  child: Text(
                    "delete_account".tr(),
                    style: TextStyle(color: Colors.red),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
