import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely2/screens/main/lessons.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';

Future settingsScreen(BuildContext context) {
  String gradesResult = user.gradeType;
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
      return Material(
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
                              color: bwColor.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          color: bwColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          )),
                      child: IconButton(
                          iconSize: 15,
                          color: wbColor,
                          onPressed: () async {
                            await getUserInfo();
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        LessonsScreen(),
                                transitionDuration: Duration(seconds: 0),
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_forward_ios_outlined)),
                    ),
                  ],
                ),
                Text("settings".tr(), style: title),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            settingsListTile(
                                context: context,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "settings/userInfo");
                                },
                                items: [
                                  Icon(FontAwesome5Solid.user,
                                      size: 15, color: primaryColor),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                      user.name == "" ? user.email : user.name),
                                  Spacer(
                                    flex: 1,
                                  ),
                                ]),
                            settingsListTile(
                              arrow: false,
                              items: [
                                Icon(CupertinoIcons.plus_slash_minus,
                                    size: 15, color: primaryColor),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("grade_result".tr()),
                                Spacer(
                                  flex: 1,
                                ),
                                DropdownButton<String>(
                                  hint: Text(gradesResult.tr()),
                                  items: <String>[
                                    'av'.tr(),
                                    'pp'.tr(),
                                  ].map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    var newValue = "av";
                                    if (value == "Pluspunkte") {
                                      newValue = "pp";
                                    } else if (value == "Pluspoints") {
                                      newValue = "pp";
                                    } else {
                                      newValue = "av";
                                    }
                                    api.updateDocument(context,
                                        documentId: user.dbID,
                                        collectionId: collectionUser,
                                        data: {
                                          "gradeType": newValue,
                                        });
                                    setState(() {
                                      gradesResult = newValue;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        decoration: boxDec(),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                          decoration: boxDec(),
                          child: Column(
                            children: [
                              settingsListTile(
                                context: context,
                                items: [
                                  Icon(FontAwesome5Solid.heart,
                                      size: 15, color: primaryColor),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("support".tr()),
                                ],
                                onTap: () {
                                  Navigator.pushNamed(context, "settings/tip");
                                },
                              ),
                              settingsListTile(
                                  items: [
                                    Icon(FontAwesome5Solid.laptop,
                                        size: 15, color: primaryColor),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("downloads".tr()),
                                  ],
                                  onTap: () => launchURL(
                                      "https://gradelyapp.com#download")),
                              settingsListTile(
                                context: context,
                                items: [
                                  Icon(FontAwesome5Solid.info_circle,
                                      size: 15, color: primaryColor),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("app_info".tr()),
                                ],
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "settings/appInfo");
                                },
                              ),
                            ],
                          ))
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
