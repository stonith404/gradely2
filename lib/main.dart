import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradely2/screens/auth/auth_home.dart';
import 'package:gradely2/screens/auth/intro_screen.dart';
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
import 'package:gradely2/components/variables.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/components/functions/api.dart';
import 'package:gradely2/screens/various/maintenance.dart';
import 'package:gradely2/themes.dart';
import 'package:gradely2/screens/various/update_app.dart';
import 'package:plausible_analytics/plausible_analytics.dart';
import 'package:showcaseview/showcaseview.dart';
import 'components/functions/app.dart';
import 'components/functions/user.dart';

bool _isSignedIn = false;
bool _isMaintenance;
var _appVersionCheck;
final plausible =
    Plausible('https://analytics.eliasschneider.com', 'app.gradelyapp.com');

Future _executeJobs() async {
  _appVersionCheck = (await minAppVersion());
  if (_appVersionCheck['isUpToDate']) {
    await getUserInfo();
    _isSignedIn = await isSignedIn();
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
  client.setEndpoint('https://gradelyapp.com/v1').setProject('60f40cb212896');

  await _executeJobs();
  runApp(EasyLocalization(
      supportedLocales: const [Locale('de'), Locale('en'), Locale('fr')],
      useOnlyLangCode: true,
      path: 'assets/translations',
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
  'settings/supportApp': (context) => SupportAppScreen(),
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
    return ShowCaseWidget(
        blurValue: 1,
        onFinish: () {
          user.showcaseViewed = true;
          api.updateDocument(context,
              collectionId: collectionUser,
              documentId: user.dbID,
              data: {'showcase_viewed': true});
        },
        builder: Builder(
          builder: (context) => MaterialApp(
              title: 'Gradely 2',
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
              theme: lightTheme,
              darkTheme: darkTheme),
        ));
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({Key key}) : super(key: key);

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
    _executeJobs();
    if (!_appVersionCheck['isUpToDate']) {
      return UpdateAppScreen(_appVersionCheck['minAppVersion'],
          _appVersionCheck['currentVersion']);
    } else if (_isMaintenance) {
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
