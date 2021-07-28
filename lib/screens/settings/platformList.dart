import 'package:flutter/material.dart';
import 'package:gradely/data.dart';
import 'package:gradely/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/shared/VARIABLES.dart';

import 'package:gradely/shared/defaultWidgets.dart';

class PlatformList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        title: Text("platforms".tr(), style: appBarTextTheme),
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
              "settings_platforms_description".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 100),
            ElevatedButton(
                style: elev(),
                onPressed: () {
                  launchURL("https://gradelyapp.com");
                },
                child: Text("settings_platforms_download_button".tr()))
          ],
        ),
      ),
    );
  }
}
