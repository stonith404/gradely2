import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

class PlatformList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(darkmode);
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
        child: ListView(
          children: [
            Image.asset(
              "assets/images/$brightness/sync.png",
              height: 250,
            ),
            SizedBox(height: 50),
            Text(
              "settings_platforms_description".tr(),
            ),
            SizedBox(height: 100),
            gradelyButton(
                onPressed: () {
                  launchURL("https://gradelyapp.com");
                },
                text: "settings_platforms_download_button".tr())
          ],
        ),
      ),
    );
  }
}
