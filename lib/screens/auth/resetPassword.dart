import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/screens/auth/signIn.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

class ResetPW extends StatefulWidget {
  @override
  _ResetPWState createState() => _ResetPWState();
}

class _ResetPWState extends State<ResetPW> {
  sendPasswordResetEmail(String email) async {
    Future result = account.createRecovery(
      email: email,
      url: 'https://user.gradelyapp.com?mode=passwordReset',
    );
    result.then((response) {
      print(response);
    }).catchError((error) {
      print(error.response);
    });
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
                          SvgPicture.asset("assets/images/logo.svg",
                              color: frontColor(), height: 60),
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
                        "reset_password".tr(),
                        style: title,
                      ),
                    ],
                  ),
                  Spacer(flex: 10),
                  TextField(
                    decoration: inputDec(label: "your_email".tr()),
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    textAlign: TextAlign.left,
                  ),
                  Spacer(
                    flex: 5,
                  ),
                  gradelyButton(
                      onPressed: () {
                        sendPasswordResetEmail(emailController.text);

                        Navigator.pushReplacement(
                          context,
                          GradelyPageRoute(builder: (context) => SignInPage()),
                        );
                        errorSuccessDialog(
                            context: context,
                            error: false,
                            text: "password_reset_success_text".tr(),
                            title: "sent".tr());
                      },
                      text: "request_link".tr()),
                  Spacer(flex: 35),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "password_remembered".tr(),
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
