import 'package:flutter/material.dart';
import 'package:gradely/GRADELY_OLD/data.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/GRADELY_OLD/shared/defaultWidgets.dart';

class PlatformList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: defaultRoundedCorners(),
        backgroundColor: primaryColor,
        title: Text("Plattformen".tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/sync.png",
              height: 250,
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
