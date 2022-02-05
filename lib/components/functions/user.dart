import 'dart:async';
import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:gradely2/components/functions/app.dart';
import 'package:gradely2/components/widgets/decorations.dart';
import 'package:gradely2/components/widgets/dialogs.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/components/variables.dart';
import 'package:gradely2/components/models.dart' as models;


//get info of current logged in user
Future getUserInfo() async {
  if (await isSignedIn()) {
    User accountR;
    if (await internetConnection()) {
      accountR = await account.get();
      prefs.setString('accountResult', jsonEncode(accountR.toMap()));
    } else {
      var prefsRes = jsonDecode(prefs.getString('accountResult'));

      accountR = User(
          $id: prefsRes['\$id'],
          name: prefsRes['name'],
          registration: prefsRes['registration'],
          status: prefsRes['status'],
          passwordUpdate: prefsRes['passwordUpdate'],
          email: prefsRes['email'],
          emailVerification: prefsRes['emailVerification'],
          prefs: Preferences(data: prefsRes['prefs']));
    }

    var dbResponse = (await api.listDocuments(
        name: 'userDB',
        collection: collectionUser,
        queries: [Query.equal('uid', accountR.$id)]))[0];

    user = models.User(
      accountR.$id,
      accountR.name,
      accountR.registration,
      accountR.status,
      accountR.passwordUpdate,
      accountR.email,
      accountR.emailVerification,
      dbResponse['gradeType'],
      dbResponse['choosenSemester'],
      dbResponse['showcase_viewed'] ?? false,
      dbResponse['\$id'],
    );
  }
}

//re authenticates the user

Future<bool> reAuthenticate(
    {@required String email, @required String password}) async {
  bool success = false;

  Future result = account.createSession(email: email, password: password);

  await result.then((response) {
    success = true;
  }).catchError((error) {
    print(error.message);
    success = false;
  });

  return success;
}

void changeEmail(_email, context) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          title: Text('action_required'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('re_enter_password_save_changes'.tr()),
              SizedBox(
                height: 20,
              ),
              TextField(
                  controller: passwordController,
                  textAlign: TextAlign.left,
                  obscureText: true,
                  decoration: inputDec(context, label: 'your_password'.tr())),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('done'.tr()),
              onPressed: () async {
                try {
                  await account.updateEmail(
                    email: _email,
                    password: passwordController.text,
                  );
                  Navigator.of(context).pop();
                  errorSuccessDialog(
                      context: context,
                      error: false,
                      text: 'email_updated'.tr());

                  Future.delayed(Duration(seconds: 2));
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    'subjects',
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print(e.message);
                  Navigator.of(context).pop();
                  errorSuccessDialog(
                      context: context, error: true, text: e.message);
                }
                passwordController.text = '';
              },
            ),
          ],
        );
      });
}

Future signOut(context) async {
  await account.deleteSession(sessionId: 'current');
  prefs.setBool('signedIn', false);
  clearVariables();
  Navigator.pushNamedAndRemoveUntil(
    context,
    'auth/home',
    (Route<dynamic> route) => false,
  );
}

Future<bool> isSignedIn() async {
  if (await internetConnection()) {
    try {
      await account.get();
      prefs.setBool('signedIn', true);
      return true;
    } catch (_) {
      prefs.setBool('signedIn', false);
      return false;
    }
  } else if (prefs.getBool('signedIn') ?? false) {
    return true;
  } else {
    return false;
  }
}

String getUserAgent() {
  String platform;
  if (Platform.isIOS) {
    platform = 'iPhone OS';
  } else if (Platform.isAndroid) {
    platform = 'Android';
  } else if (Platform.isMacOS) {
    platform = 'Mac OS X';
  } else if (Platform.isWindows) {
    platform = 'Windows';
  }

  return 'Mozilla/5.0 ($platform, Firefox)';
}
