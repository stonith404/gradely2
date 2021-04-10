import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:gradely/main.dart';
import 'package:gradely/chooseSemester.dart';
import 'data.dart';
import 'shared/defaultWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userAuth/login.dart';

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
                  icon: FaIcon(FontAwesomeIcons.signOutAlt),
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                    await FirebaseAuth.instance.signOut();
                  },
                ),
                Image.asset('assets/iconT.png', width: 50),
              ],
            ),
          ),
        ),
      ),

      pages: [
        PageViewModel(
          title: "Willkommen!",
          body:
              "Willkommen bei Gradely. Gradely hilft dir deine Noten zu überwachen.",
          image: Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: _buildImage('welcome.png'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Überall verfügbar",
          body:
              "Deine Noten werden sicher in der Cloud gespeichert. So kannst du auf deinem Laptop, Handy oder iPad Noten hinzufügen und anschauen",
          image: _buildImage('sync.png'),
          footer: Text("Mehr Infos findest du in den Einstellungen."),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Pluspunkte oder Durchschnitt?",
          body:
              "In den Einstellungen kannst du einstellen, ob es deine Resultate in Pluspunkten oder als Durschnitt anzeigen soll.",
          image: _buildImage('choose.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Fast Fertig...",
          bodyWidget: Column(
            children: [
              Text(
                "Füge ein Semester hinzu. Keine Angst, dieses kannst du später löschen oder unbennen.",
                style: TextStyle(fontSize: 19),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 45, 8, 0),
                child: TextField(
                    style: TextStyle(color: Colors.black),
                    controller: addSemesterController,
                    textAlign: TextAlign.left,
                    decoration: inputDec("Semester Name")),
              ),
            ],
          ),
          footer: ElevatedButton(
            child: Text("Hinzufügen"),
            onPressed: () {
              createSemester(addSemesterController.text);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => chooseSemester()),
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
        color: defaultBlue,
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
