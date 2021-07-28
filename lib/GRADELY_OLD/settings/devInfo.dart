import 'package:flutter/material.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gradely/GRADELY_OLD/shared/defaultWidgets.dart';

class DevInfo extends StatefulWidget {
  @override
  _DevInfoState createState() => _DevInfoState();
}

class _DevInfoState extends State<DevInfo> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String _homeScreenText = "";

  @override
  initState() {
    super.initState();
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "$token";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shape: defaultRoundedCorners(),
          backgroundColor: primaryColor,
          title: Text(
            "developer infos",
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(15, 70, 15, 50),
              child: Column(
                children: [
                  Text(
                    'Push Notifications Token:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(_homeScreenText),
                ],
              ),
            ),
          ],
        ));
  }
}