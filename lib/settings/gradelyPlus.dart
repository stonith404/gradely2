import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:gradely/main.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/userAuth/login.dart';
import 'package:gradely/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/main.dart';

// class GradelyPlusWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     if (kIsWeb) {
//       return GradelyPlusUnsupportet();
//     } else if (Platform.isAndroid || Platform.isIOS) {
//       return GradelyPlus();
//     } else {
//       return GradelyPlusUnsupportet();
//     }
//   }
// }

class GradelyPlus extends StatefulWidget {
  @override
  _GradelyPlusState createState() => _GradelyPlusState();
}

class _GradelyPlusState extends State<GradelyPlus> {
  List<Widget> productList;

   @override
  void initState() {
    super.initState();
    asyncInitState(); // async is not allowed on initState() directly
  }

  void asyncInitState() async {
    await FlutterInappPurchase.instance.initConnection;
  }

   @override
  void dispose() async{
    super.dispose();
    await FlutterInappPurchase.instance.endConnection;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(height: 20),
        Image.asset("assets/images/gradelyplus.png", height: 200),
        SizedBox(height: 40),
        Text("gradelyP1".tr()),
        SizedBox(
          height: 30,
        ),
        Container(
          decoration: boxDec(),
          child: ListTile(
            title: Row(
              children: [
                Icon(
                  FontAwesome5Solid.heart,
                  color: Colors.red[600],
                ),
                SizedBox(width: 20),
                Text("gradelyP2".tr())
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          decoration: boxDec(),
          child: ListTile(
            title: Row(
              children: [
                Icon(
                  FontAwesome5Solid.palette,
                  color: Colors.cyanAccent,
                ),
                SizedBox(width: 20),
                Text("gradelyP3".tr())
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          decoration: boxDec(),
          child: ListTile(
            title: Row(
              children: [
                Icon(
                  FontAwesome5.laugh,
                  color: Colors.amber[700],
                ),
                SizedBox(width: 20),
                Text("gradelyP6".tr())
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          decoration: boxDec(),
          child: ListTile(
            title: Row(
              children: [
                Icon(
                  FontAwesome5Solid.star,
                  color: defaultColor,
                ),
                SizedBox(width: 20),
                Text("gradelyP4".tr())
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            kIsWeb || Platform.isMacOS
                ? Text(
                    "gradelyP5".tr(),
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
                  )
                : ElevatedButton(onPressed: (){
             
    FlutterInappPurchase.instance.requestPurchase("com.eliasschneider.gradely.iap.gradelyplus");
  
                }, child: Text("buy"))
          ],
        )
      ]),
    );
  }
}
