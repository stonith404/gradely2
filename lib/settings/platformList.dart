import 'package:flutter/material.dart';
import 'package:gradely/main.dart';


class PlatformList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Plattformen"),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pla", style: TextStyle( fontWeight: FontWeight.bold, fontSize: 30),),
          Expanded(
            child: ListView(
              children: [
                ExpansionTile(title: Text("Ios"),
                children: [
                  Text("expanded"),
                ],
                ),
                                ExpansionTile(title: Text("Android"),
                children: [
                  Text("expanded"),
                ],
                ),
                                ExpansionTile(title: Text("MacOS"),
                children: [
                  Text("expanded"),
                ],
                ),
                                ExpansionTile(title: Text("Windows 10"),
                children: [
                  Text("expanded"),
                ],
                ),
                                ExpansionTile(title: Text("Web"),
                children: [
                  Text("expanded"),
                ],
                ),

              ],
            ),
          ),
          
        ],
      ),
    );
  }
}