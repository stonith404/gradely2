import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/screens/auth/introScreen.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

bool _obsecuredText = true;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  createUser() async {
    isLoadingController.add(true);
    Future resultCreateAccount = account.create(
      email: emailController.text,
      password: passwordController.text,
    );
    await resultCreateAccount.then((response) async {
      await account.createSession(
        email: emailController.text,
        password: passwordController.text,
      );
      response = jsonDecode(response.toString());

      await database.createDocument(collectionId: collectionUser, data: {
        "uid": response["\$id"],
        "gradelyPlus": false,
        "gradeType": "av",
        "choosenSemester": "noSemesterChoosed"
      });
      await getUserInfo();
      prefs.setBool("signedIn", true);
      passwordController.text = "";
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => IntroScreen()),
        (Route<dynamic> route) => false,
      );
    }).catchError((error) {
      errorSuccessDialog(context: context, error: true, text: error.message);
    });

    isLoadingController.add(false);
  }

  @override
  Widget build(BuildContext context) {
    darkModeColorChanger(context);
    return Scaffold(
      backgroundColor: defaultBGColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Column(
                children: [
                  Container(
                      alignment: AlignmentDirectional.center,
                      color: primaryColor,
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset("assets/images/logo.svg",
                                  color: Colors.white, height: 60),
                              Text(" radely",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ],
                      )),
                  //fix the small space
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    height: 1,
                    color: defaultBGColor,
                  )
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(20),
                    topEnd: Radius.circular(20),
                  ),
                  color: defaultBGColor,
                ),
                height: MediaQuery.of(context).size.height * 0.05,
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "sign_up".tr(),
                        style: title,
                      ),
                    ],
                  ),
                  Spacer(flex: 10),
                  TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      textAlign: TextAlign.left,
                      decoration: inputDec(label: "Deine Email")),
                  Spacer(flex: 5),
                  TextField(
                      controller: passwordController,
                      textAlign: TextAlign.left,
                      obscureText: _obsecuredText,
                      decoration: inputDec(
                        label: "Dein Passwort",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obsecuredText = !_obsecuredText;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye,
                              color:
                                  _obsecuredText ? Colors.grey : primaryColor),
                        ),
                      )),
                  Spacer(flex: 10),
                  gradelyButton(
                      text: "sign_up".tr(),
                      onPressed: () async {
                        await createUser();
                      }),
                  Spacer(flex: 35),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "question_have_account".tr(),
                        style: TextStyle(color: primaryColor),
                      )),
                  Spacer(flex: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
