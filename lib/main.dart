import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradely2/screens/auth/authHome.dart';
import 'package:gradely2/screens/auth/introScreen.dart';
import 'package:gradely2/screens/auth/resetPassword.dart';
import 'package:gradely2/screens/auth/signIn.dart';
import 'package:gradely2/screens/main/grades/grades.dart';
import 'package:gradely2/screens/main/subjects.dart';
import 'package:gradely2/screens/main/semesters.dart';
import 'package:gradely2/screens/settings/appInfo.dart';
import 'package:gradely2/screens/settings/contact.dart';
import 'package:gradely2/screens/settings/contribute.dart';
import 'package:gradely2/screens/settings/support.dart';
import 'package:gradely2/screens/settings/userInfo.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:gradely2/shared/api.dart';
import 'package:gradely2/shared/loading.dart';
import 'package:gradely2/shared/maintenance.dart';
import 'package:plausible_analytics/plausible_analytics.dart';

bool isLoggedIn = false;

final plausible =
    Plausible("https://analytics.eliasschneider.com", "app.gradelyapp.com");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await sharedPrefs();
  api = GradelyApi();
  client = appwrite.Client();
  account = appwrite.Account(client);
  database = appwrite.Database(client);
  locale = appwrite.Locale(client);
  storage = appwrite.Storage(client);
  functions = appwrite.Functions(client);
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

var routes = {
  '/': (context) => HomeWrapper(),
  'auth/home': (context) => AuthHomeScreen(),
  'auth/signUp': (context) => Intro1(),
  'auth/resetPassword': (context) => ResetPasswordScreen(),
  'auth/signIn': (context) => SignInScreen(),
  'semesters': (context) => SemesterScreen(),
  'subjects': (context) => SubjectScreen(),
  'grades': (context) => GradesScreen(),
  'supportApp': (context) => SupportAppScreen(),
  'settings/userInfo': (context) => UserInfoScreen(),
  'settings/contribute': (context) => ContributeScreen(),
  'settings/appInfo': (context) => AppInfoScreen(),
  'settings/contact': (context) => ContactScreen(),
  'maintenance': (context) => MaintenanceScreen(),
};

class MaterialWrapper extends StatelessWidget {
  const MaterialWrapper({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gradely 2",
      initialRoute: '/',
      onGenerateRoute: (settings) {
        plausible.enabled = kDebugMode || kIsWeb ? false : true;
        plausible.userAgent = getUserAgent();
        plausible.event(page: settings.name);
        return GradelyPageRoute(
            builder: (context) => routes[settings.name](context));
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
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
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.white),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: frontColor()),
        ),
        backgroundColor: Color(0xFF010001),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
    internetConnection(context: context);
    client.setLocale(Localizations.localeOf(context).toString());
//this future builder gets the user data and returns the semester detail page when done.
    return FutureBuilder(
      future: isMaintenance(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return LoadingScreen();
        } else if (snapshot.data == true) {
          return MaintenanceScreen();
        } else {
          return FutureBuilder(
              future: getUserData,
              builder: (BuildContext context, AsyncSnapshot snap) {
                if (snap.data == null) {
                  return LoadingScreen();
                } else {
                  if (prefs.getBool("signedIn") ?? false || !snap.hasError) {
                    return SubjectScreen();
                  } else {
                    return AuthHomeScreen();
                  }
                }
              });
        }
      },
    );
  }
}
