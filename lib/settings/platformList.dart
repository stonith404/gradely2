import 'package:flutter/material.dart';
import 'package:gradely/data.dart';
import 'package:gradely/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gradely/shared/defaultWidgets.dart';

class PlatformList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: defaultColor,
        title: Text("Plattformen".tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Image.asset(
              "assets/images/sync.png",
              height: 200,
            ),
            SizedBox(height: 50),
            Text(
              "pl1".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
                "Auf 'gradelyapp.com' kannst du Gradely für all deine Gerät herunterladen."
                    .tr()),
            SizedBox(height: 15),
            SizedBox(height: 50),
            SizedBox(height: 50),
            ElevatedButton(
                style: elev(),
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
