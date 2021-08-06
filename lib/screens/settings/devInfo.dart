import 'package:flutter/material.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/defaultWidgets.dart';

class DevInfo extends StatefulWidget {
  @override
  _DevInfoState createState() => _DevInfoState();
}

class _DevInfoState extends State<DevInfo> {

  String _homeScreenText = "";


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
        body: ListView(
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
