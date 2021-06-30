import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradely/chooseSemester.dart';
import 'package:gradely/data.dart';
import 'package:gradely/shared/loading.dart';
import 'userAuth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/semesterDetail.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

bool isLoggedIn = false;
Color defaultColor = Color(0xFF6C63FF);

List<String> testList = [];
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
  if (defaultTargetPlatform == TargetPlatform.android) {
    // For play billing library 2.0 on Android, it is mandatory to call
    // [enablePendingPurchases](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.Builder.html#enablependingpurchases)
    // as part of initializing the app.
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
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
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => HomeWrapper(),
        // When navigating to the "/second" route, build the SecondScreen widget.
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(defaultColor),
        )),
        fontFamily: "Nunito",
        dialogBackgroundColor: Colors.grey[300],
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        brightness: Brightness.light,
        primaryColor: defaultColor,
        scaffoldBackgroundColor: Color(0xFFE5E8F2),
        backgroundColor: Colors.grey[300],
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(defaultColor),
        )),
        dialogBackgroundColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[900],
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

  getLessons() async {


    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(
            'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
        .orderBy("average", descending: true)
        .get();
    List<DocumentSnapshot> documents = result.docs;

    setState(() {
      courseList = [];
      courseListID = [];

      allAverageList = [];
      allAverageListPP = [];
      semesterAveragePP = [];
      emojiList = [];
      documents.forEach((data) {
        courseList.add(data["name"]);
        courseListID.add(data.id);
        allAverageList.add(data["average"]);
        try {
          emojiList.add(data["emoji"]);
        } catch (e) {
          emojiList.add("");
        }
      });

      documents.forEach((data) {
        getPluspointsallAverageList(data["average"]);
        if (data["average"].isNaN) {
          allAverageListPP.add(0.toString());
          semesterAveragePP.add(0);
        } else {
          allAverageListPP.add(plusPointsallAverageList.toString());
          semesterAveragePP.add(plusPointsallAverageList);
        }
      });
    });
    //getSemesteraverage
    num _pp = 0;

    for (num e in semesterAveragePP) {
      _pp += e;
    }
    setState(() {
      averageOfSemesterPP = _pp;
    });

    //get average of all

    double _sum = 0;
    double _anzahl = 0;
    for (num e in allAverageList) {
      if (e.isNaN) {
      } else {
        _sum += e;
        _anzahl = _anzahl + 1;
        setState(() {
          averageOfSemester = _sum / _anzahl;
        });
      }
    }
  }
  @override
  void initState() {
    super.initState();
       


       getLessons();
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snapshot) {
          // Added this line
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          }
          if (snapshot.data == null) {
            return LoginScreen();
          }

          return HomeSite();
        });
  }
}
