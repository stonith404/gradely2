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


class GradelyPlusWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return GradelyPlusUnsupportet();
    } else if (Platform.isAndroid || Platform.isIOS) {

      return GradelyPlus();
    } else {
   return GradelyPlusUnsupportet();

    }
  }
}

const bool _kAutoConsume = true;

const String _kConsumableId = 'com.eliasschneider.gradely.iap.gradelyplus';

const List<String> _kProductIds = <String>[
  _kConsumableId,
];

class GradelyPlus extends StatefulWidget {
  @override
  GradelyPlusState createState() => GradelyPlusState();
}

class GradelyPlusState extends State<GradelyPlus> {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  @override
  void initState() {
     ErrorWidget.builder = (FlutterErrorDetails details) => gpUI(productList: [ElevatedButton(onPressed: null, child: Text("Loading".tr(),), style: elev())]);
    getPlusStatus();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }

    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = verifiedPurchases;
      _notFoundIds = productDetailResponse.notFoundIDs;

      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildProductList(),
          ],
        ),
      );
    } else {
      stack.add(      gpUI(productList: []));
    }
    if (_purchasePending) {
      stack.add(
      gpUI(productList: [ElevatedButton(onPressed: null, child: Text("Loading".tr(),), style: elev())]));
      
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: defaultColor,
        title: const Text('gradely plus'),
      ),
      body: Stack(
        children: stack,
      ),
    );
  }

  Widget _buildProductList() {
    List<Widget> productList = <Widget>[];

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        return ElevatedButton(
          style: elev(),
          child: Text(productDetails.price),
          onPressed: () {
            // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
            // verify the latest status of you your subscription by using server side receipt validation
            // and update the UI accordingly. The subscription purchase status shown
            // inside the app may not be accurate.

            PurchaseParam purchaseParam = PurchaseParam(
              productDetails: productDetails,
              applicationUserName: null,
            );
            if (productDetails.id == _kConsumableId) {
              _connection.buyConsumable(
                  purchaseParam: purchaseParam,
                  autoConsume: _kAutoConsume || Platform.isIOS);
            } else {
              _connection.buyNonConsumable(purchaseParam: purchaseParam);
            }
          },
        );
      },
    ));

    return gradelyPlus ? Text("premium") : gpUI(productList: productList);
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    DocumentSnapshot _db = await FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .get();

    FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .update({'gradelyPlus': true});

    setState(() {
      _purchases.add(purchaseDetails);
      _purchasePending = false;
    });
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

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            await InAppPurchaseConnection.instance
                .consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }
}

class gpUI extends StatelessWidget {
  const gpUI({
    Key key,
    @required this.productList,
  }) : super(key: key);

  final List<Widget> productList;

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
                  color: Colors.amber[700],
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
          children: [kIsWeb || Platform.isMacOS ? Text("gradelyP5".tr(), style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),) : productList[0]],
        )
      ]),
    );
  }
}

class GradelyPlusUnsupportet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("gradely plus"),),
        body: gpUI(productList: [],));
  }
}
