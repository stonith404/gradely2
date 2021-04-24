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

//flutter is awesome
//2021

bool isLoggedIn = false;
const defaultBlue = Color(0xFF6C63FF);
var testList = [];
var courseListID = [];
var allAverageList = [];
var allAverageListPP = [];
String selectedLesson = "";
String selectedLessonName;
double averageOfSemester = 0 / -0;
num averageOfSemesterPP = 0 / -0;
String choosenSemesterName = "noSemesterChoosed";
var wbColor;
var bwColor;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  runApp(EasyLocalization(
    supportedLocales: [Locale('de'), Locale('en')],
    useOnlyLangCode: true,
    path: 'assets/translations',
    fallbackLocale: Locale('en'),
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
             scaffoldBackgroundColor:  Colors.grey[300],
             backgroundColor: Colors.grey[300],
       
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(defaultBlue)),
        ),
      ),
      darkTheme: ThemeData(
      backgroundColor: Colors.grey[900],
        scaffoldBackgroundColor:  Colors.grey[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(defaultBlue)),
        ),
       
        brightness: Brightness.dark,
        primaryColor: defaultBlue,
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: defaultBlue),
      ),
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
