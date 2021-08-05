import 'package:flutter/material.dart';
import 'package:gradely/screens/main/chooseSemester.dart';
import 'package:gradely/screens/settings/contact.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/shared/WIDGETS.dart';
import 'package:gradely/shared/defaultWidgets.dart';

class Contribute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        title: Text("contribute".tr(), style: appBarTextTheme),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset("assets/images/$brightness/love.png", height: 200),
            SizedBox(
              height: 15,
            ),
            whiteContainer(children: [
              Text(
                "contribute_leading_text".tr(),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            whiteContainer(children: [
              Text(
                "languages".tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "contribute_translate_p1".tr() + "\n",
              ),
              Text(
                "contribute_translate_p2".tr() + "\n\n",
              ),
              Text("bug_or_improvement",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                  .tr(),
              Text(
                "contribute_feature_bug_suggestion".tr() + "\n\n",
              ),
              Text("or_something_else".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 30,
            ),
            gradelyButton(
                text: "contact_me".tr(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactScreen()),
                  );
                })
          ],
        ),
      ),
    );
  }
}

Widget whiteContainer({List<Widget> children}) {
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        color: bwColor),
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    ),
  );
}
