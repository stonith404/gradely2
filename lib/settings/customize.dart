import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/userAuth/login.dart';
import 'package:easy_localization/easy_localization.dart';

List _colorList = [
  Color(0xFF6C63FF),
  Color(0xFF4a47a3),
  Color(0xFF709fb0),
  Color(0xFFa7c5eb),
  Color(0xFF440a67),
  Color(0xFF93329e),
  Color(0xFFFF69B4),
  Color(0xFFb4aee8),
  Color(0xFF693c72),
  Color(0xFFc15050),
  Color(0xFFd97642),
  Color(0xFFd49d42),
  Color(0xFF00af91),
  Color(0xFF007965),
  Color(0xFFd00587a),
  Color(0xFF000000)
];

class CustomizeT extends StatefulWidget {
  @override
  _CustomizeTState createState() => _CustomizeTState();
}

class _CustomizeTState extends State<CustomizeT> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: defaultColor,
        title: Text(
          "customize".tr(),
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
     
            
      Expanded(
              child: ListView.builder(
                
                  scrollDirection: Axis.horizontal,
                itemCount: _colorList.length,
                itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                        onTap: () {
                          setState(() {
                            defaultColor = _colorList[index];
                          });
                          FirebaseFirestore.instance
                              .collection('userData')
                              .doc(auth.currentUser.uid)
                              .update({
                            'defaultColor':
                                "#${(defaultColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}"
                          });
                        },
                    child: Container(
                      width: 50,
                        decoration: BoxDecoration(
                      color: _colorList[index],
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(25),
                      ),
                    )),
                  );
                  
                },
              ),
            ),
          
          Text(_colorList.length.toString() ?? "zroo")
        ],
      ),
    );
  }
}

Color pickerColor = Color(0xff443a49);
Color currentColor = Color(0xff443a49);

class Customize extends StatefulWidget {
  @override
  _CustomizeState createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: defaultColor,
        title: Text(
          "customize".tr(),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("custom1".tr(), style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 20),
            Container(
              height: 100,
              child: Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            defaultColor = _colorList[index];
                          });
                          FirebaseFirestore.instance
                              .collection('userData')
                              .doc(auth.currentUser.uid)
                              .update({
                            'defaultColor':
                                "#${(defaultColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}"
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _colorList[index],
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(25),
                            ),
                          ),
                        ));
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
