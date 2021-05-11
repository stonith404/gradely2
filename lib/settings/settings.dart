import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/introScreen.dart';
import 'package:gradely/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
    getgradesResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          shape: defaultRoundedCorners(),
          backgroundColor: defaultColor,
          title: Text("Einstellungen".tr()),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeWrapper()),
                  (Route<dynamic> route) => false,
                );
              })),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Icon(FontAwesome5Solid.laptop, size: 15),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Plattformen".tr()),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlatformList()),
                    );
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(
                          gradelyPlus
                              ? FontAwesome5Solid.palette
                              : FontAwesome5Solid.star,
                          size: 17),
                      SizedBox(
                        width: 10,
                      ),
                      Text(gradelyPlus ? "customize".tr() : "Gradely Plus"),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => gradelyPlus
                              ? CustomizeT()
                              : GradelyPlusWrapper()),
                    );
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FontAwesome5Solid.user_graduate, size: 15),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Noten Resultate".tr()),
                      Spacer(flex: 1),
                      DropdownButton<String>(
                        hint: Text(gradesResult),
                        items: <String>[
                          'Durchschnitt',
                          'Pluspunkte',
                        ].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {
                          FirebaseFirestore.instance
                              .collection('userData')
                              .doc(auth.currentUser.uid)
                              .update({'gradesResult': _});
                          setState(() {
                            gradesResult = _;
                          });

                          print(gradesResult);
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FontAwesome5Solid.user, size: 15),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Account"),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserInfoScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FontAwesome5Solid.envelope, size: 15),
                      SizedBox(
                        width: 10,
                      ),
                      Text("contactDev".tr()),
                    ],
                  ),
                  onTap: () {
                    if (kIsWeb) {
                      launchURL("https://gradelyapp.com");
                    } else {
                                          Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactScreen()),
                    );
                    }

                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FontAwesome5Solid.redo, size: 15),
                      SizedBox(
                        width: 10,
                      ),
                      Text("restartIntro".tr()),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IntroScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              "www.gradelyapp.com",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }
}
