import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/LessonsDetail.dart';
import 'package:gradely/introScreen.dart';
import 'package:gradely/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/semesterDetail.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../userAuth/login.dart';
import 'package:gradely/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'platformList.dart';
import 'contact.dart';
import 'gradelyPlus.dart';
import 'customize.dart';
import 'package:gradely/data.dart';
import 'userInfo.dart';
import '../shared/defaultWidgets.dart';
import '../data.dart';

Future settingsScreen(BuildContext context) {
  return showCupertinoModalBottomSheet(
    shadow: BoxShadow(
      color: Colors.grey.withOpacity(0.3),
      spreadRadius: 5,
      blurRadius: 7,
      offset: Offset(0, 3), // changes position of shadow
    ),
    context: context,
    builder: (context) => StatefulBuilder(builder:
        (BuildContext context, StateSetter setState /*You can rename this!*/) {
      return SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Material(
          color: defaultBGColor,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(25),
                            )),
                        child: IconButton(
                            iconSize: 15,
                            color: Colors.black,
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          HomeSite(),
                                  transitionDuration: Duration(seconds: 0),
                                ),
                              );
                            },
                            icon: Icon(Icons.arrow_forward_ios_outlined)),
                      ),
                    ],
                  ),
                  Text(
                    "Einstellungen".tr(),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          child: settingsListTile(
                              context: context,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserInfoScreen()),
                                );
                              },
                              items: [
                                Icon(FontAwesome5Solid.user, size: 15),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(auth.currentUser.displayName == null
                                    ? auth.currentUser.email
                                    : auth.currentUser.displayName),
                                Spacer(
                                  flex: 1,
                                ),
                              ]),
                          decoration: whiteBoxDec(),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: whiteBoxDec(),
                          child: Column(
                            children: [
                              settingsListTile(
                                  items: [
                                    Icon(FontAwesome5Solid.laptop, size: 15),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Plattformen".tr()),
                                  ],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PlatformList()),
                                    );
                                  }),
                              Divider(),
                              SizedBox(
                                child: settingsListTile(
                                    items: [
                                      Icon(
                                          gradelyPlus
                                              ? FontAwesome5Solid.palette
                                              : FontAwesome5Solid.star,
                                          size: 17),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(gradelyPlus
                                          ? "customize".tr()
                                          : "Gradely Plus"),
                                    ],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => gradelyPlus
                                                ? CustomizeT()
                                                : GradelyPlus()),
                                      );
                                    }),
                              ),
                              Divider(),
                              settingsListTile(
                                arrow: false,
                                items: [
                                  Icon(CupertinoIcons.plus_slash_minus,
                                      size: 15),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Noten Resultate".tr()),
                                  Spacer(
                                    flex: 1,
                                  ),
                                  DropdownButton<String>(
                                    hint: Text(gradesResult.tr()),
                                    items: <String>[
                                      'Durchschnitt'.tr(),
                                      'Pluspunkte'.tr(),
                                    ].map((String value) {
                                      return new DropdownMenuItem<String>(
                                        value: value,
                                        child: new Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      var newValue = "Pluspunkte";
                                      if (value == "Pluspunkte") {
                                        newValue = "Pluspunkte";
                                      } else if (value == "pluspoints") {
                                        newValue = "Pluspunkte";
                                      } else {
                                        newValue = "Durchschnitt";
                                      }
                                      FirebaseFirestore.instance
                                          .collection('userData')
                                          .doc(auth.currentUser.uid)
                                          .update({'gradesResult': newValue});
                                      setState(() {
                                        gradesResult = newValue;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: whiteBoxDec(),
                          child: Column(
                            children: [
                              settingsListTile(
                                items: [
                                  Icon(FontAwesome5Solid.envelope, size: 15),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("contactDev".tr()),
                                ],
                                onTap: () {
                                  if (kIsWeb) {
                                    launchURL("https://gradelyapp.com");
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ContactScreen()),
                                    );
                                  }
                                },
                              ),
                              settingsListTile(
                                items: [
                                  Icon(FontAwesome5Solid.redo, size: 15),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("restartIntro".tr()),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => IntroScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "www.gradelyapp.com",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }),
  );
}

ListTile settingsListTile({
  BuildContext context,
  List<Widget> items,
  onTap,
  arrow = true,
}) {
  if (arrow) {
    items.add(
      Spacer(
        flex: 1,
      ),
    );
    items.add(
      Icon(CupertinoIcons.forward),
    );
  }

  return ListTile(title: Row(children: items), onTap: onTap);
}
