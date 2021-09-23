import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradely2/screens/auth/signIn.dart';
import 'package:gradely2/screens/main/lessons.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/shared/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isLoggedIn = false;

List<String> testList = [];
var courseListID = [];
var allAverageList = [];
var allAverageListPP = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await sharedPrefs();

  client = appwrite.Client();
  account = appwrite.Account(client);
  database = appwrite.Database(client);
  locale = appwrite.Locale(client);
  storage = appwrite.Storage(client);
  client
      .setEndpoint('https://aw.cloud.eliasschneider.com/v1')
      .setProject('60f40cb212896');

  runApp(EasyLocalization(
      supportedLocales: [Locale('de'), Locale('en')],
      useOnlyLangCode: true,
      path: 'assets/translations/gradelyTranslation.csv',
      assetLoader: CsvAssetLoader(),
      fallbackLocale: Locale('en'),
      saveLocale: true,
      child: MaterialWrapper()));
}

Future<bool> isGradelyNewVersion() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("newGradely") ?? true;
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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(frontColor()),
        )),
        dialogBackgroundColor: Color(0xFFF2F2F7),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: frontColor()),
        ),
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
        backgroundColor: Colors.grey[300],
      ),
      darkTheme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: frontColor()),
        ),
        backgroundColor: Color(0xFF010001),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(frontColor()),
        )),
        dialogBackgroundColor: Color(0xFF1a1a1a),
        scaffoldBackgroundColor: Color(0xFF010001),
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
  Future getUserData;
  @override
  void initState() {
    super.initState();

    getUserData = getUserInfo();
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  }

  @override
  Widget build(BuildContext context) {
    client.setLocale(Localizations.localeOf(context).toString());
//this future builder gets the user data and returns the semester detail page when done.
    return FutureBuilder(
        future: getUserData,
        builder: (BuildContext context, AsyncSnapshot snap) {
          if (snap.data == null) {
            return LoadingScreen();
          } else {
            if (prefs.getBool("signedIn") ?? false) {
              return SemesterDetail();
            } else {
              return SignInPage();
            }
          }
        });
  }
}
