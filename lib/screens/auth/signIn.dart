import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/main.dart';
import 'package:gradely2/screens/auth/signUp.dart';
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
      prefs.remove("newGradely");
      prefs.setBool("signedIn", true);
      await getUserInfo();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeWrapper()),
      );

      passwordController.text = "";
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
                        "sign_in".tr(),
                        style: title,
                      ),
                    ],
                  ),
                  Spacer(flex: 10),
                  TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      textAlign: TextAlign.left,
                      decoration: inputDec(label: "your_email".tr())),
                  Spacer(flex: 5),
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
                              color:
                                  _obsecuredText ? Colors.grey : primaryColor),
                        ),
                      )),
                  Spacer(flex: 10),
                  gradelyButton(
                      text: "sign_in".tr(), onPressed: () => signInUser()),
                  Spacer(flex: 35),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
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
                          MaterialPageRoute(builder: (context) => ResetPW()),
                        );
                      },
                      child: Text(
                        "question_forgot_password".tr(),
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
