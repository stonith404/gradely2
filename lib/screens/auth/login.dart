import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely/main.dart';
import 'package:gradely/screens/auth/register.dart';
import 'package:gradely/screens/auth/resetPassword.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/WIDGETS.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _obsecuredText = true;

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  signInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FocusScope.of(context).unfocus();
    Future result = account.createSession(
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    result.then((response) async {
      setState(() {
        isLoading = false;
      });

      prefs.remove("newGradely");
      prefs.setBool("signedIn", true);
      await getUserInfo();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeWrapper()),
      );

      passwordController.text = "";
      print(response);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      errorSuccessDialog(context: context, error: true, text: error.message);
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
                      text: "Anmelden",
                      onPressed: () async {
                        await signInUser();
                        passwordController.text = "";
                      }),
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
