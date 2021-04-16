import 'package:flutter/material.dart';
import 'package:gradely/introScreen.dart';
import 'package:gradely/main.dart';
import 'aboutDev.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../userAuth/login.dart';
import 'package:gradely/data.dart';
import 'aboutApp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'platformList.dart';
import 'contact.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    getgradesResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  title: Text("Plattformen".tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlatformList()),
                    );
                  },
                ),
                 ListTile(
                  title: Text("contactDev".tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactScreen()),
                    );
                  },
                ),
                
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Noten Resultate".tr()),
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
                  title: Text("restartIntro".tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IntroScreen()),
                    );
                  },
                ),
                ListTile(
                  title: Text("App Info"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AppInfo()),
                    );
                  },
                ),
                ListTile(
                  title: Text("Logout"),
                  onTap: () async {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                    );

                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              "Made with ❤️ by Elias Schneider",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }
}
