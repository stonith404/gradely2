import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/components/functions/user.dart';
import 'package:gradely2/components/widgets/buttons.dart';
import 'package:gradely2/components/widgets/decorations.dart';
import 'package:gradely2/components/widgets/dialogs.dart';
import 'package:gradely2/components/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _obsecuredText = true;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  signInUser() async {
    isLoadingController.add(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future result = account.createSession(
      email: emailController.text,
      password: passwordController.text,
    );
    await result.then((response) async {
      prefs.setBool("signedIn", true);
      await getUserInfo();
      Navigator.pushNamed(context, "subjects");

      passwordController.text = "";
    }).catchError((error) {
      print(error);
      errorSuccessDialog(context: context, error: true, text: error.message);
    });
    isLoadingController.add(false);
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardActive = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(
              flex: keyboardActive ? 8 : 6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/images/logo.svg",
                    color: Theme.of(context).primaryColorDark,
                    height: keyboardActive ? 60 : 30),
                keyboardActive
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "sign_in".tr(),
                          style: title,
                        ),
                      )
              ],
            ),
            Spacer(
              flex: keyboardActive ? 4 : 1,
            ),
            keyboardActive
                ? Row(
                    children: [
                      Text(
                        "sign_in".tr(),
                        style: title,
                      ),
                    ],
                  )
                : Container(),
            Spacer(
              flex: 2,
            ),
            TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                textAlign: TextAlign.left,
                decoration: inputDec(context, label: "your_email".tr())),
            Spacer(
              flex: 1,
            ),
            TextField(
                controller: passwordController,
                textAlign: TextAlign.left,
                obscureText: _obsecuredText,
                decoration: inputDec(
                  context,
                  label: "your_password".tr(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obsecuredText = !_obsecuredText;
                      });
                    },
                    icon: Icon(Icons.remove_red_eye,
                        color: _obsecuredText
                            ? Colors.grey
                            : Theme.of(context).primaryColorDark),
                  ),
                )),
            Spacer(flex: keyboardActive ? 4 : 2),
            gradelyButton(text: "sign_in".tr(), onPressed: () => signInUser()),
            Spacer(flex: 12),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "auth/home");
                },
                child: Text(
                  "question_no_account".tr(),
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "auth/resetPassword");
                },
                child: Text(
                  "question_forgot_password".tr(),
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                )),
            Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
