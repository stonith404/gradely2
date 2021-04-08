import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'aboutDev.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../userAuth/login.dart';
import 'package:gradely/data.dart';

import 'platformList.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Einstellungen"),
       leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },)),
      body: ListView(
        children: [
          ListTile(
            title: Text("Plattformen"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlatformList()),
              );
            },
          ),
          ListTile(
            title: Text("Noten Resultate"),
            subtitle: DropdownButton<String>(
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
                setState(() {
                          gradesResult = _;        
                                });
                
                print(gradesResult);
              },
            ),
          ),
          ListTile(
            title: Text("Logout"),
            onTap: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
