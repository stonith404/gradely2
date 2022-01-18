import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthHomeScreen extends StatefulWidget {
  @override
  _AuthHomeScreenState createState() => _AuthHomeScreenState();
}

class _AuthHomeScreenState extends State<AuthHomeScreen> {
  @override
  Widget build(BuildContext context) {
    darkModeColorChanger(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Spacer(
              flex: 12,
            ),
            SvgPicture.asset(
              "assets/images/logo.svg",
              color: Theme.of(context).primaryColorDark,
              height: 100,
            ),
            Spacer(
              flex: 4,
            ),
            FittedBox(
              child: Text(
                "welcome_to_gradely".tr(),
                textAlign: TextAlign.center,
                style: bigTitle,
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Text("grades_across".tr()),
            Spacer(
              flex: 20,
            ),
            Container(
                width: 300,
                child: gradelyButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "auth/signUp",
                      );
                    },
                    text: "get_started".tr())),
            Spacer(
              flex: 1,
            ),
            Container(
              width: 300,
              child: gradelyButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "auth/signIn");
                  },
                  text: "sign_in".tr(),
                  color: Theme.of(context).primaryColorLight,
                  textColor: Theme.of(context).primaryColorDark),
            ),
            Spacer(
              flex: 8,
            ),
          ]),
        ),
      ),
    );
  }
}
