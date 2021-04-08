import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'aboutDev.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../userAuth/login.dart';

import 'platformList.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Einstellungen")),
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
            title: Text("Logout"),
            onTap:
             () async {
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
