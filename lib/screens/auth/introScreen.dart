import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely2/screens/auth/signIn.dart';
import 'package:gradely2/screens/main/lessons.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class IntroScreen extends StatefulWidget {
  int initPage;

  IntroScreen({this.initPage = 0});
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Widget _buildImage(String assetName, [double width = 350]) {
    return SvgPicture.asset(
      'assets/images/$assetName',
      width: width,
      color: primaryColor,
    );
  }

  @override
  void initState() {
    super.initState();
    account.createVerification(
        url: "https://user.gradelyapp.com/#/verifyEmail");
  }

  @override
  Widget build(BuildContext context) {
    darkModeColorChanger(context);
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      initialPage: widget.initPage,
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
                    await signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      GradelyPageRoute(builder: (context) => SignInPage()),
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
            padding: const EdgeInsets.only(top: 120.0),
            child: _buildImage(
              "BalletDoodle.svg",
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("everywhere_available".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          body: "intro_messaqge_sync".tr(),
          image: _buildImage('MeditatingDoodle.svg'),
          footer: Text("intro_more_in_settings".tr()),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("pluspoints_or_average".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          body: "grade_result_change_in_settings".tr(),
          image: _buildImage('MessyDoodle.svg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("add_first_semester".tr(),
              textAlign: TextAlign.center,
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
                    decoration: inputDec(label: "Semester Name")),
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
                  data: {
                    "parentId": user.dbID,
                    "name": addSemesterController.text
                  });

              result.then((response) {
                response = jsonDecode(response.toString());

                database.updateDocument(
                    collectionId: collectionUser,
                    documentId: user.dbID,
                    data: {"choosenSemester": response["\$id"]});
              }).catchError((error) {
                print(error.response);
              });

              errorSuccessDialog(
                  context: context,
                  error: false,
                  text: "success_semester_added".tr());

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
        PageViewModel(
          titleWidget: Text("almost_finished".tr(),
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          bodyWidget: Column(
            children: [
              Text(
                "intro_email_verification".tr() + " " + user.email,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19),
              ),
              Text(
                "\n" + "check_email_spam".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          footer: Column(
            children: [
              gradelyButton(
                text: "i_verified_email".tr(),
                onPressed: () async {
                  isLoadingController.add(true);
                  await getUserInfo();
                  if (user.emailVerification) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      GradelyPageRoute(builder: (context) => SemesterDetail()),
                      (Route<dynamic> route) => false,
                    );
                    errorSuccessDialog(
                        context: context,
                        error: false,
                        text: "success_email_verified".tr());
                  } else {
                    errorSuccessDialog(
                        context: context,
                        error: true,
                        text: "error_email_not_verified".tr());
                  }

                  isLoadingController.add(false);
                },
              ),
              TextButton(
                  onPressed: () {
                    Future result = account.createVerification(
                        url: "https://user.gradelyapp.com/#/verifyEmail");

                    result.then((response) {
                      errorSuccessDialog(
                          context: context,
                          error: false,
                          text: "success_email_sent".tr());
                    }).catchError((error) {
                      errorSuccessDialog(
                          context: context, error: true, text: error.message);
                    });
                  },
                  child: Text("send_again".tr())),
              Theme(
                data: ThemeData().copyWith(
                    dividerColor: Colors.transparent,
                    colorScheme: ColorScheme.fromSwatch()
                        .copyWith(secondary: primaryColor)),
                child: ExpansionTile(
                  textColor: primaryColor,
                  collapsedTextColor: primaryColor,
                  trailing: SizedBox.shrink(),
                  expandedAlignment: Alignment.center,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("      " + "change_email".tr()),
                    ],
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                              style: TextStyle(color: wbColor),
                              keyboardType: TextInputType.emailAddress,
                              controller: changeEmailController,
                              textAlign: TextAlign.left,
                              decoration: inputDec(label: "email".tr())),
                        ),
                        IconButton(
                          onPressed: () async {
                            try {
                              changeEmail(changeEmailController.text, context);
                            } catch (e) {
                              errorSuccessDialog(
                                  context: context,
                                  error: true,
                                  text: e.message);
                            }
                          },
                          icon: Icon(FontAwesome5Solid.save),
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
      showSkipButton: false,
      skipFlex: 0,
      nextFlex: 0,
      next: const Icon(Icons.arrow_forward),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        activeColor: primaryColor,
        color: primaryColor,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
