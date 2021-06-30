import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:gradely/main.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/userAuth/login.dart';
import 'package:gradely/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gradely/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class GradelyPlusWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradelyPlus();
  }
}

class InApp extends StatefulWidget {
  @override
  _InAppState createState() => new _InAppState();
}

class _InAppState extends State<InApp> {
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  final List<String> _productLists = [
    'com.eliasschneider.gradely.iap.gradelyplus',
    'com.eliasschneider.gradely.iap.gradelyplus2',
    'com.eliasschneider.gradely.iap.gradelyplus5'
  ];

  String _platformVersion = 'Unknown';
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

  void _requestPurchase(IAPItem item) {
    FlutterInappPurchase.instance.requestPurchase(item.productId);
  }

  Future _getProduct() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }

    setState(() {
      this._items = items;
      this._purchases = [];
    });
  }

  List<Widget> _renderInApps() {
    List<Widget> widgets = this
        ._items
        .map((item) => Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        item.toString(),
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                      color: Colors.orange,
                      onPressed: () {
                        print("---------- Buy Item Button Pressed");
                        this._requestPurchase(item);
                      },
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 48.0,
                              alignment: Alignment(-1.0, 0.0),
                              child: Text('Buy Item'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
    return widgets;
  }

  List<Widget> _renderPurchases() {
    List<Widget> widgets = this
        ._purchases
        .map((item) => Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        item.toString(),
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ))
        .toList();
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 20;
    double buttonWidth = (screenWidth / 3) - 20;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    'Running on: $_platformVersion\n',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          width: buttonWidth,
                          height: 60.0,
                          margin: EdgeInsets.all(7.0),
                          child: FlatButton(
                            color: Colors.amber,
                            padding: EdgeInsets.all(0.0),
                            onPressed: () async {
                              print(
                                  "---------- Connect Billing Button Pressed");
                              await FlutterInappPurchase
                                  .instance.initConnection;
                              await FlutterInappPurchase
                                  .instance.consumeAllItems;
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              alignment: Alignment(0.0, 0.0),
                              child: Text(
                                'Connect Billing',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: buttonWidth,
                          height: 60.0,
                          margin: EdgeInsets.all(7.0),
                          child: FlatButton(
                            color: Colors.amber,
                            padding: EdgeInsets.all(0.0),
                            onPressed: () async {},
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              alignment: Alignment(0.0, 0.0),
                              child: Text(
                                'End ee',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                              width: buttonWidth,
                              height: 60.0,
                              margin: EdgeInsets.all(7.0),
                              child: FlatButton(
                                color: Colors.green,
                                padding: EdgeInsets.all(0.0),
                                onPressed: () {
                                  print("---------- Get Items Button Pressed");
                                  this._getProduct();
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  alignment: Alignment(0.0, 0.0),
                                  child: Text(
                                    'Get Items',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              )),
                        ]),
                  ],
                ),
                Column(
                  children: this._renderInApps(),
                ),
                Column(
                  children: this._renderPurchases(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
//______________-

class GradelyPlus extends StatefulWidget {
  @override
  _GradelyPlusState createState() => _GradelyPlusState();
}

class _GradelyPlusState extends State<GradelyPlus> {
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;

  buyProduct(String id) async {
    await FlutterInappPurchase.instance.clearTransactionIOS();
    await FlutterInappPurchase.instance.consumeAllItems;
    await FlutterInappPurchase.instance.getProducts([id]);
    await FlutterInappPurchase.instance.requestPurchase(id);
  }

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
    initPlatformState();
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
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    if (!mounted) return;

    // refresh items for android
    try {
 await FlutterInappPurchase.instance.consumeAllItems;
  
    } catch (err) {
  
    }

    _conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      gradelyDialog(context: context, title: "error", text: "errror");
    });
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
                      onPressed: () async {},
                      child: Text("☕️ Espresso 1\$")),
                  ElevatedButton(
                      style: elev(),
                      onPressed: () async {},
                      child: Text("🧋 ${'coffee'.tr()} 2\$")),
                  ElevatedButton(
                      style: elev(),
                      onPressed: () async {},
                      child: Text("🧊 ${'ice coffee'.tr()} 5\$")),
                ])),
      ),
    );
  }
}
