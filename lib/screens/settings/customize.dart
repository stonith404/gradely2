import 'package:flutter/material.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'settings.dart';
import 'package:easy_localization/easy_localization.dart';

List _colorList = [
  Color(0xff000000),
  Color(0xFF6C63FF),
  Color(0xFF5BC89E),
  Color(0xFF308991),
  Color(0xFF2B194D),
  Color(0xFF5B2060),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            SizedBox(height: 30),
            Container(
              padding: EdgeInsetsDirectional.all(20),
              decoration: boxDec(),
              height: 220,
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
                  SizedBox(
                    height: 20,
                  ),
                  gradelyButton(
                      text: "save",
                      onPressed: () {
                        database.updateDocument(
                            collectionId: collectionUser,
                            documentId: user.dbID,
                            data: {
                              'color':
                                  "#${(primaryColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}"
                            });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        settingsScreen(context);
                      })
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
