import 'package:flutter/material.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/defaultWidgets.dart';
import 'settings.dart';
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
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        title: Text("customize".tr(), style: appBarTextTheme),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined, color: primaryColor),
            onPressed: () {
              database.updateDocument(
                  collectionId: collectionUser,
                  documentId: user.dbID,
                  data: {
                    'color':
                        "#${(primaryColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}"
                  });

              settingsScreen(context);
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            SizedBox(height: 30),
            Container(
              padding: EdgeInsetsDirectional.all(20),
              decoration: whiteBoxDec(),
              height: 180,
              child: Column(
                children: [
                  Text("change_app_colors".tr(),
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colorList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              primaryColor = _colorList[index];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                                height: 1,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: _colorList[index],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(65),
                                  ),
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        shape: defaultRoundedCorners(),
        backgroundColor: primaryColor,
        title: Text(
          "customize".tr(),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_outlined,
            ),
            onPressed: () {
              settingsScreen(context);
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("change_app_colors".tr(),
                style: TextStyle(fontWeight: FontWeight.w700)),
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
                            primaryColor = _colorList[index];
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
