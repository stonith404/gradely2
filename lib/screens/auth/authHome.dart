import 'package:gradely2/screens/auth/introScreen.dart';
import 'package:gradely2/screens/auth/signIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

class AuthHome extends StatefulWidget {
  @override
  _AuthHomeState createState() => _AuthHomeState();
}

class _AuthHomeState extends State<AuthHome> {
  @override
  Widget build(BuildContext context) {
    darkModeColorChanger(context);
    return Scaffold(
      backgroundColor: defaultBGColor,
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Spacer(
            flex: 12,
          ),
          SvgPicture.asset(
            "assets/images/logo.svg",
            color: primaryColor,
            height: 100,
          ),
          Spacer(
            flex: 4,
          ),
          Text(
            "Welcome to Gradely 2",
            style: bigTitle,
          ),
          Spacer(
            flex: 1,
          ),
          Text("Your grades across all your devices"),
          Spacer(
            flex: 20,
          ),
          Container(
              width: 300,
              child: gradelyButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      GradelyPageRoute(
                          builder: (context) => IntroScreenWrapper(1)),
                    );
                  },
                  text: "Get started")),
          Spacer(
            flex: 1,
          ),
          Container(
            width: 300,
            child: gradelyButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    GradelyPageRoute(builder: (context) => SignInPage()),
                  );
                },
                text: "Sign In",
                color: frontColor(),
                textColor: primaryColor),
          ),
          Spacer(
            flex: 8,
          ),
        ]),
      ),
    );
  }
}
