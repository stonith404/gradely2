import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:gradely2/shared/loading.dart';

class TipScreen extends StatefulWidget {
  @override
  _TipScreenState createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  StreamSubscription purchaseUpdatedSubscription;
  StreamSubscription purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  List iapList = [];

  buyProduct(String id) async {
    isLoadingController.add(true);
    initPlatformState();
    await FlutterInappPurchase.instance.clearTransactionIOS();

    await getProducts();
    await FlutterInappPurchase.instance.requestPurchase(id);
  }

  getProducts() async {
    await FlutterInappPurchase.instance.initConnection;
    if (Platform.isIOS || Platform.isAndroid) {
      await FlutterInappPurchase.instance.clearTransactionIOS();
      iapList = (await FlutterInappPurchase.instance.getProducts([
        "com.eliasschneider.gradely2.iap.gradelyplus",
        "com.eliasschneider.gradely2.iap.gradelyplus2",
        "com.eliasschneider.gradely2.iap.gradelyplus5"
      ]));
      setState(() {
        iapList = iapList;
      });
    }
  }

  finishPurchase(token) async {
    FlutterInappPurchase.instance.consumePurchaseAndroid(token);
    isLoadingController.add(false);

    gradelyDialog(
        context: context,
        title: "thank_you".tr(),
        text: "tip_success_text".tr());
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
    if (purchaseErrorSubscription != null) {
      purchaseErrorSubscription.cancel();
      purchaseErrorSubscription = null;
    }
    if (purchaseUpdatedSubscription != null) {
      purchaseUpdatedSubscription.cancel();
      purchaseUpdatedSubscription = null;
    }
  }

  Future<void> initPlatformState() async {
    // prepare
    await FlutterInappPurchase.instance.initConnection;

    if (!mounted) return;

    purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      finishPurchase(productItem.purchaseToken);
    });

    purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      isLoadingController.add(false);
      print('purchase-error: $purchaseError');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        title: Text("support".tr(), style: appBarTextTheme),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(children: [
              SizedBox(height: 10),
              Text(
                "tip_description".tr(),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "tip".tr(),
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 10,
              ),
              iapList.isEmpty && (Platform.isIOS || Platform.isAndroid)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradelyLoadingIndicator(),
                      ],
                    )
                  : Platform.isIOS || Platform.isAndroid
                      ? Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              gradelyButton(
                                  onPressed: () async {
                                    buyProduct(
                                        "com.eliasschneider.gradely2.iap.gradelyplus");
                                  },
                                  text:
                                      "☕️ ${iapList[0].localizedPrice ?? "-"}"),
                              gradelyButton(
                                  onPressed: () async => buyProduct(
                                      "com.eliasschneider.gradely2.iap.gradelyplus2"),
                                  text:
                                      "🍺 ${iapList[1].localizedPrice ?? "-"}"),
                              gradelyButton(
                                  onPressed: () async => buyProduct(
                                      "com.eliasschneider.gradely2.iap.gradelyplus5"),
                                  text:
                                      "🥃 ${iapList[2].localizedPrice ?? "-"}"),
                            ],
                          )
                        ])
                      : Text("tip_only_mobile".tr(),
                          style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(
                height: 40,
              ),
              Text(
                "contribute".tr(),
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "tip_contribute".tr(),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              gradelyButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, "settings/contribute"),
                  text: "contribute".tr(),
                  color: frontColor(),
                  textColor: primaryColor),
              SizedBox(
                height: 40,
              ),
              Text(
                "rate_app".tr(),
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 10,
              ),
              Text("rate_app_description".tr()),
              SizedBox(
                height: 20,
              ),
              gradelyButton(
                  onPressed: () => launchURL((() {
                        if (Platform.isIOS || Platform.isMacOS) {
                          return "https://apps.apple.com/app/gradely-2-grade-calculator/id1578749974";
                        } else if (Platform.isAndroid) {
                          return "https://play.google.com/store/apps/details?id=com.eliasschneider.gradely2";
                        } else if (Platform.isWindows) {
                          return "https://www.microsoft.com/store/apps/9MW4FPN80D7D";
                        } else {
                          return "https://gradelyapp.com";
                        }
                      }())),
                  text: "rate".tr(),
                  color: frontColor(),
                  textColor: primaryColor)
            ])),
      ),
    );
  }
}
