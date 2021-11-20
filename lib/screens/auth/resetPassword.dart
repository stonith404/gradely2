import 'package:gradely2/screens/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  sendPasswordResetEmail(String email) async {
    Future result = account.createRecovery(
      email: email,
      url: 'https://gradelyapp.com/user/changePassword',
    );
    result.then((response) {}).catchError((error) {
      print(error.response);
    });
  }

  @override
  Widget build(BuildContext context) {
    darkModeColorChanger(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: defaultBGColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(
              flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 8 : 6,
            ),
            SvgPicture.asset("assets/images/logo.svg",
                color: primaryColor, height: 60),
            Spacer(
              flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 6 : 2,
            ),
            Row(
              children: [
                Text(
                  "reset_password".tr(),
                  style: title,
                ),
              ],
            ),
            Spacer(
              flex: 2,
            ),
            TextField(
              decoration: inputDec(label: "your_email".tr()),
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              textAlign: TextAlign.left,
            ),
            Spacer(flex: 4),
            gradelyButton(
                onPressed: () {
                  sendPasswordResetEmail(emailController.text);

                  Navigator.pushNamed(context, "auth/signIn");
                  errorSuccessDialog(
                      context: context,
                      error: false,
                      text: "password_reset_success_text".tr(),
                      title: "sent".tr());
                },
                text: "request_link".tr()),
            Spacer(flex: 16),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "password_remembered".tr(),
                  style: TextStyle(color: primaryColor),
                )),
            Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
