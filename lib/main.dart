import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/shared/loading.dart';
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
import 'package:in_app_purchase/in_app_purchase.dart';

bool isLoggedIn = false;
const defaultColor = Color(0xFF6C63FF);
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
  InAppPurchaseConnection.enablePendingPurchases();
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
        appBarTheme: AppBarTheme(centerTitle: true),
        fontFamily: 'Nunito',
        brightness: Brightness.light,
        primaryColor: defaultColor,
        scaffoldBackgroundColor: Colors.grey[300],
        backgroundColor: Colors.grey[300],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(defaultColor)),
        ),
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(centerTitle: true),
        backgroundColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(defaultColor)),
        ),
        brightness: Brightness.dark,
        primaryColor: defaultColor,
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: defaultColor),
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
    if (!isLoggedIn) {
      return LoginScreen();
    } else {
      if (choosenSemester == "noSemesterChoosed") {
        return chooseSemester();
      } else {
        return HomeSite();
      }
    }
  }
}
