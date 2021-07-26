import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:gradely/GRADELY_OLD/chooseSemester.dart';
import 'data.dart';
import 'shared/defaultWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userAuth/login.dart';
import 'package:gradely/GRADELY_OLD/semesterDetail.dart';
import 'package:easy_localization/easy_localization.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HomeSite()),
    );
  }

  Widget _buildFullscrenImage() {
    return Image.asset(
      'assets/images/sync.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
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
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                    await FirebaseAuth.instance.signOut();
                  },
                ),
                Image.asset('assets/images/iconT.png', width: 50),
              ],
            ),
          ),
        ),
      ),

      pages: [
        PageViewModel(
          titleWidget: Text("Willkommen!".tr(),
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          body:
              "Willkommen bei Gradely. Gradely hilft dir deine Noten zu überwachen."
                  .tr(),
          image: Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: _buildImage('welcome.png'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("Überall verfügbar".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          body:
              "Deine Noten werden sicher in der Cloud gespeichert. So kannst du auf deinem Laptop, Handy oder iPad Noten hinzufügen und anschauen"
                  .tr(),
          image: _buildImage('sync.png'),
          footer: Text("Mehr Infos findest du in den Einstellungen.".tr()),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("Pluspunkte oder Durchschnitt?".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          body:
              "In den Einstellungen kannst du einstellen, ob es deine Resultate in Pluspunkten oder als Durschnitt anzeigen soll."
                  .tr(),
          image: _buildImage('choose.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("Fast Fertig...".tr(),
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 34)),
          bodyWidget: Column(
            children: [
              Text(
                "Füge ein Semester hinzu. Keine Angst, dieses kannst du später löschen oder unbenennen."
                    .tr(),
                style: TextStyle(fontSize: 19),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 45, 8, 0),
                child: TextField(
                    controller: addSemesterController,
                    textAlign: TextAlign.left,
                    decoration: inputDec("Semester Name".tr())),
              ),
            ],
          ),
          footer: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: primaryColor,
            ),
            child: Text("hinzufügen".tr()),
            onPressed: () {
              createSemester(addSemesterController.text);
              HapticFeedback.mediumImpact();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ChooseSemester()),
                (Route<dynamic> route) => false,
              );

              addLessonController.text = "";
              semesterList = [];
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
