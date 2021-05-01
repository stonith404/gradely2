import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'package:gradely/data.dart';
import 'package:provider/provider.dart';
import 'package:gradely/shared/theme.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'settings.dart';

class Customize extends StatefulWidget {
  @override
  _CustomizeState createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(backgroundColor: defaultColor, title: Text("custom",), leading: IconButton(
        
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                  (Route<dynamic> route) => false,
                );
              }),),
        body: Column(
          children: [
            SizedBox(height: 60),
            ElevatedButton(
                style: elev(),
                onPressed: () {
                  setState(() {
                    defaultColor = Colors.red;
                  });
                },
                child: Text("change"))
          ],
        ),
      ),
    );
  }
}
