import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'package:gradely/data.dart';
import 'package:provider/provider.dart';
import 'package:gradely/shared/theme.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'settings.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/userAuth/login.dart';

 // create some values
                  Color pickerColor = Color(0xff443a49);
                  Color currentColor = Color(0xff443a49);

class Customize extends StatefulWidget {
  @override
  _CustomizeState createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: defaultColor,
          title: Text(
            "custom",
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                  (Route<dynamic> route) => false,
                );
              }),
        ),
        body: Column(
          children: [
            SizedBox(height: 60),
            ElevatedButton(
                style: elev(),
                onPressed: () {
                 

// ValueChanged<Color> callback
                  void changeColor(Color color) {
                    setState(() => defaultColor = color);
                  }

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              availableColors: [Color(0xFF6C63FF), Color(0xFFFF69B4)],
                              pickerColor: pickerColor,
                              onColorChanged: changeColor,
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text('Got it'),
                              onPressed: () {
                              
                               
                                setState(() => currentColor = pickerColor);
                                  FirebaseFirestore.instance
                                    .collection('userData')
                                    .doc(auth.currentUser.uid)
                                    .update({
                                  'defaultColor':
                                      "#${(defaultColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}"
                                });
                                 print(
                                  "eeeee" + currentColor.toString());
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                },
                child: Text("change"))
          ],
        ),
      ),
    );
  }
}
