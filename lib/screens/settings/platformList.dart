import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

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
        child: ListView(
          children: [
            SvgPicture.asset(
              'assets/images/MeditatingDoodle.svg',
              width: 250,
              color: primaryColor,
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
