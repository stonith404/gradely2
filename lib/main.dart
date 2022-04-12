import "package:appwrite/appwrite.dart" as appwrite;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/controllers/user_controller.dart";
import "package:gradely2/screens/auth/auth_home.dart";
import "package:gradely2/screens/auth/intro_screen.dart";
import "package:gradely2/screens/auth/reset_password.dart";
import "package:gradely2/screens/auth/sign_in.dart";
import "package:gradely2/screens/main/grades/grades.dart";
import "package:gradely2/screens/main/subjects/subjects.dart";
import "package:gradely2/screens/main/semesters/semesters.dart";
import "package:gradely2/screens/settings/contact.dart";
import "package:gradely2/screens/settings/contribute.dart";
import "package:gradely2/screens/settings/support.dart";
import "package:gradely2/screens/settings/user_info.dart";
import "package:gradely2/components/variables.dart";
import "package:easy_localization/easy_localization.dart";
import "package:gradely2/components/utils/api.dart";
import "package:gradely2/screens/various/maintenance.dart";
import "package:gradely2/themes.dart";
import "package:gradely2/screens/various/update_app.dart";
import "package:plausible_analytics/plausible_analytics.dart";
import "package:showcaseview/showcaseview.dart";
import "components/utils/app.dart";
import "env.dart" as env;

final navigatorKey = GlobalKey<NavigatorState>();
bool _isSignedIn = false;
bool? _isMaintenance;
final UserController _userController = UserController();
late var _appVersionCheck = {};
final plausible = Plausible(env.PLAUSIBLE_ENDPOINT, "app.gradelyapp.com");

Future _executeJobs() async {
  _appVersionCheck = (await minAppVersion());
  if (_appVersionCheck["isUpToDate"]) {
    await _userController.getUserInfo();
    _isSignedIn = await _userController.isSignedIn();
    _isMaintenance = await isMaintenance();
  }
}

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
  client.setEndpoint(env.APPWRITE_ENDPOINT).setProject(env.APPWRITE_PROJECT_ID);

  await _executeJobs();
  runApp(EasyLocalization(
      supportedLocales: const [Locale("de"), Locale("en"), Locale("fr")],
      useOnlyLangCode: true,
      path: "assets/translations",
      fallbackLocale: Locale("en"),
      saveLocale: true,
      child: MaterialWrapper()));
}

var routes = {
  "/": (context) => HomeWrapper(),
  "auth/home": (context) => AuthHomeScreen(),
  "auth/signUp": (context) => Intro1(),
  "auth/resetPassword": (context) => ResetPasswordScreen(),
  "auth/signIn": (context) => SignInScreen(),
  "semesters": (context) => SemesterScreen(),
  "subjects": (context) => SubjectScreen(),
  "grades": (context) => GradesScreen(),
  "settings/supportApp": (context) => SupportAppScreen(),
  "settings/userInfo": (context) => UserInfoScreen(),
  "settings/contribute": (context) => ContributeScreen(),
  "settings/contact": (context) => ContactScreen(),
  "maintenance": (context) => MaintenanceScreen(),
};

class MaterialWrapper extends StatelessWidget {
  const MaterialWrapper({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
        blurValue: 1,
        onFinish: () {
          user.showcaseViewed = true;
          api.updateDocument(context,
              collectionId: collectionUser,
              documentId: user.dbID,
              data: {"showcase_viewed": true});
        },
        builder: Builder(
          builder: (context) => MaterialApp(
              title: "Gradely 2",
              initialRoute: "/",
              navigatorKey: navigatorKey,
              onGenerateRoute: (settings) {
                plausible.enabled = kDebugMode || kIsWeb ? false : true;
                plausible.userAgent = _userController.getUserAgent();
                plausible.event(page: settings.name!);
                return GradelyPageRoute(
                    builder: (context) => routes[settings.name!]!(context));
              },
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              themeMode: kIsWeb ? ThemeMode.light : ThemeMode.system,
              theme: lightTheme,
              darkTheme: darkTheme),
        ));
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<HomeWrapper> {
  Future? getUserData;
  @override
  void initState() {
    super.initState();
    getUserData = _userController.getUserInfo();
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  }

  @override
  Widget build(BuildContext context) {
    internetConnection();
    client.setLocale(Localizations.localeOf(context).toString());
    _executeJobs();
    if (!_appVersionCheck["isUpToDate"]) {
      return UpdateAppScreen(_appVersionCheck["minAppVersion"],
          _appVersionCheck["currentVersion"]);
    } else if (_isMaintenance!) {
      return MaintenanceScreen();
    } else {
      if (_isSignedIn) {
        return SubjectScreen();
      } else {
        return AuthHomeScreen();
      }
    }
  }
}
