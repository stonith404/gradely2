import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradely/GRADELY_OLD/chooseSemester.dart';
import 'package:gradely/GRADELY_OLD/data.dart';
import 'package:gradely/GRADELY_OLD/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/GRADELY_OLD/semesterDetail.dart';
import 'package:gradely/GRADELY_OLD/userAuth/login.dart';

bool isLoggedIn = false;
Color primaryColor = Color(0xFF6C63FF);

List<String> testList = [];
var courseListID = [];
var allAverageList = [];
var allAverageListPP = [];
String selectedLesson = "";
String selectedLessonName;
double averageOfSemester = 0 / -0;
num averageOfSemesterPP = 0 / -0;
String choosenSemesterName = "noSemesterChoosed";

 mainGradelyOLD() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();
  runApp(EasyLocalization(
    supportedLocales: [Locale('de'), Locale('en')],
    useOnlyLangCode: true,
    path: 'assets/translations',
    fallbackLocale: Locale('en'),
    saveLocale: true,
    child: OLDMaterialWrapper(),
  ));
}

class OLDMaterialWrapper extends StatelessWidget {
  const OLDMaterialWrapper({
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
          foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
        )),
        fontFamily: "Nunito",
        dialogBackgroundColor: Colors.grey[300],
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Color(0xFFf2f2f7),
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
          foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
        )),
        dialogBackgroundColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[900],
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: primaryColor),
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

gradelyOLDinfo(context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Gradely Migration"),
          content: Text("gradely_migration_info".tr()),
          actions: <Widget>[
            TextButton(
              child: Text("ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
