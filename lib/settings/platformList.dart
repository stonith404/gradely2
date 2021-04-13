import 'package:flutter/material.dart';
import 'package:gradely/data.dart';
import 'package:gradely/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class PlatformList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plattformen".tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text(
              "Die Plattformen und Synchronisation macht Gradely einzigartig."
                  .tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
                "Auf 'gradelyapp.com' kannst du Gradely für all deine Gerät herunterladen."
                    .tr()), 
            SizedBox(height: 15),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FaIcon(FontAwesomeIcons.appStoreIos),
                FaIcon(FontAwesomeIcons.android),
                FaIcon(FontAwesomeIcons.appStoreIos),
                FaIcon(FontAwesomeIcons.chrome),
              ],
            ),
            SizedBox(height: 50),
            ElevatedButton(
                onPressed: () {
                  launchURL("https://gradelyapp.com");
                },
                child: Text("pl3".tr()))
          ],
        ),
      ),
    );
  }
}
