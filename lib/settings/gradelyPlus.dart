import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:gradely/main.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/userAuth/login.dart';
import 'package:gradely/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/main.dart';
import 'package:super_easy_in_app_purchase/super_easy_in_app_purchase.dart';

class GradelyPlusWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradelyPlus();
  }
}

class GradelyPlus extends StatefulWidget {
  @override
  _GradelyPlusState createState() => _GradelyPlusState();
}

class _GradelyPlusState extends State<GradelyPlus> {
  SuperEasyInAppPurchase inAppPurchase;

  finishPurchase() async {
    await getUIDDocuments();

    FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .update({'gradelyPlus': true});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeWrapper()),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("🎉 " + "gradelyPS1".tr()),
            content: Text("gradelyPS2".tr()),
            actions: <Widget>[
              FlatButton(
                color: defaultColor,
                child: Text("ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                  HapticFeedback.lightImpact();
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    inAppPurchase = SuperEasyInAppPurchase(
      // Any of these function will run when its corresponding product gets purchased successfully
      // For simplicity, I have just printed a message to console
      whenSuccessfullyPurchased: <String, Function>{
        'com.eliasschneider.gradely.iap.gradelyplus': () async =>
            finishPurchase(),
        'com.eliasschneider.gradely.iap.gradelyplus2': () async =>
            finishPurchase(),
        'com.eliasschneider.gradely.iap.gradelyplus5': () async =>
            finishPurchase(),
      },
    );
  }

  @override
  void dispose() {
    inAppPurchase.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gradely Plus"),
        shape: defaultRoundedCorners(),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "description".tr(),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("gradelyP1".tr()),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "features".tr(),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: whiteBoxDec(),
                    child: Column(
                      children: [
                        Container(
                          decoration: boxDec(),
                          child: ListTile(
                            title: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.heart,
                                  color: defaultColor,
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
                                  CupertinoIcons.color_filter,
                                  color: defaultColor,
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
                                  color: defaultColor,
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
                                  CupertinoIcons.star,
                                  color: defaultColor,
                                ),
                                SizedBox(width: 20),
                                Text("gradelyP4".tr())
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "gradelyPExpl".tr(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      style: elev(),
                      onPressed: () async {
                        await inAppPurchase.startPurchase(
                            'com.eliasschneider.gradely.iap.gradelyplus',
                            isConsumable: true);

                        print("done");
                      },
                      child: Text("☕️ Espresso 1\$")),
                  ElevatedButton(
                      style: elev(),
                      onPressed: () async {
                        await inAppPurchase.startPurchase(
                            'com.eliasschneider.gradely.iap.gradelyplus2',
                            isConsumable: true);

                        print("done");
                      },
                      child: Text("🧋 ${'coffee'.tr()} 2\$")),
                  ElevatedButton(
                      style: elev(),
                      onPressed: () async {
                        await inAppPurchase.startPurchase(
                            'com.eliasschneider.gradely.iap.gradelyplus5',
                            isConsumable: true);
                      },
                      child: Text("🧊 ${'ice coffee'.tr()} 5\$")),
                ])),
      ),
    );
  }
}
