import 'package:gradely2/screens/auth/authHome.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/main.dart';
import 'package:gradely2/screens/auth/resetPassword.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _obsecuredText = true;

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  signInUser() async {
    isLoadingController.add(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future result = account.createSession(
      email: emailController.text,
      password: passwordController.text,
    );
    await result.then((response) async {
      print(response);
      prefs.remove("newGradely");
      prefs.setBool("signedIn", true);
      await getUserInfo();
      Navigator.pushReplacement(
        context,
        GradelyPageRoute(builder: (context) => HomeWrapper()),
      );

      passwordController.text = "";
    }).catchError((error) {
      print(error);
      errorSuccessDialog(context: context, error: true, text: error.message);
    });
    isLoadingController.add(false);
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
              flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 4 : 2,
            ),
            SvgPicture.asset("assets/images/logo.svg",
                color: primaryColor, height: 60),
            Spacer(flex: 2),
            Row(
              children: [
                Text(
                  "sign_in".tr(),
                  style: title,
                ),
              ],
            ),
            Spacer(
              flex: 1,
            ),
            TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                textAlign: TextAlign.left,
                decoration: inputDec(label: "your_email".tr())),
            Spacer(
              flex: 1,
            ),
            TextField(
                controller: passwordController,
                textAlign: TextAlign.left,
                obscureText: _obsecuredText,
                decoration: inputDec(
                  label: "your_password".tr(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obsecuredText = !_obsecuredText;
                      });
                    },
                    icon: Icon(Icons.remove_red_eye,
                        color: _obsecuredText ? Colors.grey : primaryColor),
                  ),
                )),
            Spacer(flex: 2),
            gradelyButton(text: "sign_in".tr(), onPressed: () => signInUser()),
            Spacer(flex: 6),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    GradelyPageRoute(builder: (context) => AuthHome()),
                  );
                },
                child: Text(
                  "question_no_account".tr(),
                  style: TextStyle(color: primaryColor),
                )),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    GradelyPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
                child: Text(
                  "question_forgot_password".tr(),
                  style: TextStyle(color: primaryColor),
                )),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
