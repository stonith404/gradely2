import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:gradely2/main.dart';
import 'package:gradely2/screens/settings/heartAnimation.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:gradely2/shared/loading.dart';

class GradelyPlusScreen extends StatefulWidget {
  @override
  _GradelyPlusScreenState createState() => _GradelyPlusScreenState();
}

class _GradelyPlusScreenState extends State<GradelyPlusScreen> {
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

    api.updateDocument(context,
        collectionId: collectionUser,
        documentId: user.dbID,
        data: {'gradelyPlus': true});

    if (user.gradelyPlus) {
      gradelyDialog(
          context: context,
          title: "thank_you".tr(),
          text: "gradely_plus_active_thanks".tr());
    } else {
      Navigator.push(
        context,
        GradelyPageRoute(builder: (context) => HomeWrapper()),
      );

      gradelyDialog(
          context: context,
          title: "🎉 Wohooo",
          text: "gradely_pluss_success_text".tr());
    }
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
      body: iapList.isEmpty && (Platform.isIOS || Platform.isAndroid)
          ? Column(
              children: [
                GradelyLoadingIndicator(),
              ],
            )
          : SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(children: [
                    SizedBox(height: 10),
                    Text("tip_description".tr()),
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
                    Platform.isIOS || Platform.isAndroid
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
                        : Text("gradely_plus_mobile_only".tr(),
                            style: TextStyle(fontStyle: FontStyle.italic)),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "contribute".tr(),
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      "Gradely 2's Code is opensource, if you want you can help to improve Gradely 2 with your skills",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    gradelyButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, "settings/contribute"),
                        text: "contribute".tr()),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Send Heart".tr(),
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text("You can also send me a free heart".tr()),
                    SizedBox(
                      height: 10,
                    ),
                    gradelyButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  HeartScreen(),
                              transitionDuration: Duration.zero,
                            ),
                          ).then((value) => Future.delayed(
                              Duration(seconds: 1),
                              () => gradelyDialog(
                                  context: context,
                                  title: "title",
                                  text: "text")));
                        },
                        text: "❤️",
                        color: frontColor())
                  ])),
            ),
    );
  }
}
