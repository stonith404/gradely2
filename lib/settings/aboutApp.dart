import 'package:gradely/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easy_localization/easy_localization.dart';
import 'devInfo.dart';
import 'package:flutter/services.dart';

String appVersion = "";
String appbuildNumber = "";

class AppInfo extends StatefulWidget {
  @override
  _AppInfoState createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (kIsWeb) {
    } else {
      setState(() {
        appVersion = packageInfo.version;
        appbuildNumber = packageInfo.buildNumber;
        appVersion = "Version: $appVersion";
        appbuildNumber = "Build: $appbuildNumber";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAppInfo();
  }

  int _lastTap = DateTime.now().millisecondsSinceEpoch;
  int _consecutiveTaps = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: defaultColor,
        title: Text("App Infos"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Spacer(
              flex: 2,
            ),
            GestureDetector(
              onTap: () {
                int now = DateTime.now().millisecondsSinceEpoch;
                if (now - _lastTap < 1000) {
                  _consecutiveTaps++;

                  if (_consecutiveTaps > 9) {
                    HapticFeedback.heavyImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DevInfo()),
                    );
                  }
                } else {
                  _consecutiveTaps = 0;
                }
                _lastTap = now;
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  "assets/icon/logo.jpg",
                  height: 130,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(appVersion),
            Text(appbuildNumber),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Spacer(
              flex: 1,
            ),
            Text(
                "Gradely wurde von einem Schüler, für Schüler erstellt. Ich freue mich wenn ihr Verbesserungsvorschläge oder Ideen habt. Gerne könnt ihr mich unter elias@eliasschneider.com kontaktieren."
                    .tr()),
            Spacer(
              flex: 8,
            ),
          ],
        ),
      ),
    );
  }
}
