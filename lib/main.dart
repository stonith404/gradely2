import 'package:appwrite/appwrite.dart' hide Locale;
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradely/screens/auth/sign_in.dart';
import 'package:gradely/screens/main/semesterDetail.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';
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
  client = Client();
  account = Account(client);
  database = Database(client);

  client
      .setEndpoint('https://aw.cloud.eliasschneider.com/v1')
      .setProject('60f40cb212896');
  await getUserInfo();
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
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
        )),
        dialogBackgroundColor: Colors.grey[300],
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
        backgroundColor: Colors.grey[300],
      ),
      darkTheme: ThemeData(
        fontFamily: "Nunito",
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Color(0xFF010001),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
        )),
        dialogBackgroundColor: Color(0xFF010001),
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
  aw() async {
    await getUserInfo();
  }

  @override
  void initState() {
    super.initState();
    aw();
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  }

  @override
  Widget build(BuildContext context) {
    client.setLocale(Localizations.localeOf(context).toString());
    if (prefs.getBool("signedIn")) {
      return SemesterDetail();
    } else {
      return SignInPage();
    }
  }
}
