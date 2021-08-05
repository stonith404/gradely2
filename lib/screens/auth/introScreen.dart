import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely/screens/auth/login.dart';
import 'package:gradely/screens/main/chooseSemester.dart';
import 'package:gradely/screens/main/semesterDetail.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/WIDGETS.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:gradely/main.dart';

import 'package:easy_localization/easy_localization.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$brightness/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  color: primaryColor,
                  icon: Icon(FontAwesome5Solid.sign_out_alt),
                  onPressed: () async {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
                SvgPicture.asset("assets/images/logo.svg",
                    color: primaryColor, height: 30),
              ],
            ),
          ),
        ),
      ),

      pages: [
        PageViewModel(
          titleWidget: Text("welcome".tr(),
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          body: "intro_gradely_helps_monitoring".tr(),
          image: Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: _buildImage('welcome.png'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("everywhere_available".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          body: "intro_messaqge_sync".tr(),
          image: _buildImage('sync.png'),
          footer: Text("intro_more_in_settings".tr()),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("pluspoints_or_average".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          body: "grade_result_change_in_settings".tr(),
          image: _buildImage('choose.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("almost_finished".tr(),
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          bodyWidget: Column(
            children: [
              Text(
                "intro_add_semester".tr(),
                style: TextStyle(fontSize: 19),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 45, 8, 0),
                child: TextField(
                    controller: addSemesterController,
                    textAlign: TextAlign.left,
                    decoration: inputDec(label: "Semester Name".tr())),
              ),
            ],
          ),
          footer: gradelyButton(
            text: "add".tr(),
            onPressed: () async {
              isLoadingController.add(true);
              await getUserInfo();
              Future result = database.createDocument(
                  collectionId: collectionSemester,
                  parentDocument: user.dbID,
                  parentProperty: "semesters",
                  parentPropertyType: "append",
                  data: {"name": addSemesterController.text});

              result.then((response) {
                response = jsonDecode(response.toString());

                database.updateDocument(
                    collectionId: collectionUser,
                    documentId: user.dbID,
                    data: {"choosenSemester": response["\$id"]});
              }).catchError((error) {
                print(error.response);
              });

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SemesterDetail()),
                (Route<dynamic> route) => false,
              );

              addLessonController.text = "";
              semesterList = [];
              isLoadingController.add(false);
            },
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            bodyAlignment: Alignment.center,
            imageAlignment: Alignment.topCenter,
          ),
          reverse: true,
        ),
      ],

      showDoneButton: false,
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),

      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFF6C63FF),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
