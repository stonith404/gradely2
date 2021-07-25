import 'package:appwrite/appwrite.dart' hide Locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/loading.dart';
import 'auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/semesterDetail.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();

  client = Client();
  account = Account(client);
  database = Database(client);

  client
      .setEndpoint('https://aw.cloud.eliasschneider.com/v1')
      .setProject('60f40cb212896');
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
    return FutureBuilder<bool>(
      future: getUserInfo(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        } else {
          if (snapshot.data == false)
            return LoginScreen();
          else
            return HomeSite();
        }
      },
    );
  }
}


