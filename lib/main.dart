import 'package:flutter/material.dart';
import 'package:gradely/shared/loading.dart';
import 'userAuth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/semesterDetail.dart';


bool isLoggedIn = false;
var defaultColor = Color(0xFF6C63FF);
Color backgroundColor = Color(0xFFE5E8F2);
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
        scaffoldBackgroundColor: backgroundColor,
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
        scaffoldBackgroundColor:backgroundColor,
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
  @override
  void initState() {
    super.initState();
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
