import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:easy_localization/easy_localization.dart';

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
              onPressed: () => signOut(context))
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
                    builder: (BuildContext contextP) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
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
                                        'https://gradelyapp.com/user/changePassword',
                                  );
                                  result.then((response) {
                                    errorSuccessDialog(
                                        context: context,
                                        error: false,
                                        text:
                                            "password_reset_success_text".tr(),
                                        title: "sent".tr());
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
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            title: Text("delete_account".tr()),
                            content: Container(
                              height: 150,
                              child: Column(
                                children: [
                                  Text("delete_account_text".tr()),
                                  SizedBox(height: 30),
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
                                      await functions.createExecution(
                                          functionId: "fcn_delete_account");
                                      clearVariables();
                                      passwordController.text = "";
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        "auth/home",
                                        (Route<dynamic> route) => false,
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
