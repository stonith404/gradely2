import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'userAuth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared/defaultWidgets.dart';
import 'chooseSemester.dart';
import 'dart:math' as math;
import 'settings/settings.dart';
import 'package:gradely/introScreen.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/semesterDetail.dart';

bool isLoggedIn = false;
const defaultBlue = Color(0xFF6C63FF);
var testList = [];
var courseListID = [];
var allAverageList = [];
var allAverageListPP = [];
String selectedLesson = "";
String selectedLessonName;
double averageOfLessons = 0 / -0;
num averageOfLessonsPP = 0 / -0;
String choosenSemesterName = "noSemesterChoosed";
var wbColor = Colors.white;
var bwColor = Colors.black;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EasyLocalization(
    supportedLocales: [Locale('de'), Locale('en')],
    useOnlyLangCode: true,
    path: 'assets/translations',
    fallbackLocale: Locale('de'),
    saveLocale: true,
    child: MaterialWrapper(),
  ));
}

class MaterialWrapper extends StatelessWidget {
  const MaterialWrapper({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: HomeWrapper(),
      theme: ThemeData(
        fontFamily: 'Nunito',
        brightness: Brightness.light,
        primaryColor: defaultBlue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(defaultBlue)),
        ),
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: defaultBlue,
          appBarTheme:
              AppBarTheme(color: Colors.black87, foregroundColor: Colors.white),
          textTheme: TextTheme(
            subhead: TextStyle(color: Colors.white),
            title: TextStyle(color: Colors.white),
          )),
    );
  }
}

class HomeWrapper extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<HomeWrapper> {
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => darkModeColorChanger());
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        setState(() {
          isLoggedIn = false;
        });
      } else {
        setState(() {
          isLoggedIn = true;
        });
      }
    });
  }

  darkModeColorChanger() {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      setState(() {
        bwColor = Colors.black;
        wbColor = Colors.white;
      });
    } else {
      bwColor = Colors.white;
      wbColor = Colors.black;
    }
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    getChoosenSemester();
    if (isLoggedIn) {
      if (choosenSemester == "noSemesterChoosed") {
        return chooseSemester();
      } else {
        return HomeSite();
      }
    } else {
      return LoginScreen();
    }
  }
}
