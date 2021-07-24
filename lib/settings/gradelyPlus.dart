import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:gradely/main.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/auth/login.dart';
import 'package:gradely/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

bool _isLoading = false;

class GradelyPlusWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return GradelyPlusUnsupportet();
    } else if (Platform.isIOS || Platform.isAndroid) {
      return GradelyPlus();
    } else {
      return GradelyPlusUnsupportet();
    }
  }
}

class GradelyPlusUnsupportet extends StatelessWidget {
  const GradelyPlusUnsupportet({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gradely Plus",
        ),
        shape: defaultRoundedCorners(),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(children: [
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
                            color: primaryColor,
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
                            color: primaryColor,
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
                            color: primaryColor,
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
                            color: primaryColor,
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
            Text("gradelyP5".tr(),
                style: TextStyle(fontStyle: FontStyle.italic))
          ]),
        ),
      ),
    );
  }
}

class GradelyPlus extends StatefulWidget {
  @override
  _GradelyPlusState createState() => _GradelyPlusState();
}

class _GradelyPlusState extends State<GradelyPlus> {
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  List iapList = [];

  buyProduct(String id) async {
    setState(() {
      _isLoading = true;
    });
    initPlatformState();
    await FlutterInappPurchase.instance.clearTransactionIOS();

    await getProducts();
    await FlutterInappPurchase.instance.requestPurchase(id);
  }

  getProducts() async {
    await FlutterInappPurchase.instance.initConnection;
    await FlutterInappPurchase.instance.clearTransactionIOS();
    iapList = (await FlutterInappPurchase.instance.getProducts([
      "com.eliasschneider.gradely.iap.gradelyplus",
      "com.eliasschneider.gradely.iap.gradelyplus2",
      "com.eliasschneider.gradely.iap.gradelyplus5"
    ]));
    setState(() {
      iapList = iapList;
    });
    print(iapList);
  }

  finishPurchase() async {
    setState(() {
      _isLoading = false;
    });
    await getUIDDocuments();

    FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .update({'gradelyPlus': true});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeWrapper()),
    );
    HapticFeedback.heavyImpact();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("🎉 " + "gradelyPS1".tr()),
            content: Text("gradelyPS2".tr()),
            actions: <Widget>[
              FlatButton(
                color: primaryColor,
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
    getProducts();
  }

  @override
  void dispose() {
    super.dispose();
    if (_conectionSubscription != null) {
      _conectionSubscription.cancel();
      _conectionSubscription = null;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // prepare
    await FlutterInappPurchase.instance.initConnection;

    if (!mounted) return;

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('puelias: $productItem');
      finishPurchase();
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      setState(() {
        _isLoading = false;
      });
      print('purchase-error: $purchaseError');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Gradely Plus"),
          shape: defaultRoundedCorners(),
        ),
        body: iapList.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            : Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(children: [
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
                                        color: primaryColor,
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
                                        color: primaryColor,
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
                                        color: primaryColor,
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
                                        color: primaryColor,
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
                        Platform.isIOS || Platform.isAndroid
                            ? Column(children: [
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
                                      buyProduct(
                                          "com.eliasschneider.gradely.iap.gradelyplus");
                                    },
                                    child: Text(
                                        "☕️ Espresso ${iapList[0].localizedPrice ?? "-"}")),
                                ElevatedButton(
                                    style: elev(),
                                    onPressed: () async => buyProduct(
                                        "com.eliasschneider.gradely.iap.gradelyplus2"),
                                    child: Text(
                                        "🧋 ${'coffee'.tr()} ${iapList[1].localizedPrice ?? "-"}")),
                                ElevatedButton(
                                    style: elev(),
                                    onPressed: () async => buyProduct(
                                        "com.eliasschneider.gradely.iap.gradelyplus5"),
                                    child: Text(
                                        "🧊 ${'ice coffee'.tr()} ${iapList[2].localizedPrice ?? "-"}")),
                              ])
                            : Text("gradelyP5".tr(),
                                style: TextStyle(fontStyle: FontStyle.italic))
                      ]),
                    ),
                  ),
                  _isLoading
                      ? CircularProgressIndicator(
                          color: primaryColor,
                        )
                      : Container()
                ],
              ));
  }
}
