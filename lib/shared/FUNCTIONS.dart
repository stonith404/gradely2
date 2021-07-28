import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/screens/main/chooseSemester.dart';
import 'package:gradely/shared/CLASSES.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/WIDGETS.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future getUserInfo() async {
  var accountResponse;

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (await internetConnection()) {
    

    Future  accountResult = account.get();

    await accountResult.then((r) async {
      accountResponse = r.toString();

      await prefs.setString("accountResult", accountResponse);
    }).catchError((error) {
  
    });
  } else {
    accountResponse = prefs.getString("accountResult");
  }

  accountResponse = jsonDecode(accountResponse.toString());

  if(accountResponse == null){
 prefs.setBool("signedIn", false);
  }else{
      Future dbResult = listDocuments(
      name: "userDB",
      collection: collectionUser,
      filters: ["uid=${accountResponse['\$id']}"]);

  await dbResult.then((dbResponse) {
    dbResponse = jsonDecode(dbResponse.toString())["documents"][0];

  

    user = User(
        accountResponse['\$id'],
        accountResponse['name'],
        accountResponse['registration'],
        accountResponse['status'],
        accountResponse['passwordUpdate'],
        accountResponse['email'],
        accountResponse['emailVerification'],
        dbResponse["gradelyPlus"],
        dbResponse["gradeType"],
        dbResponse["choosenSemester"],
        dbResponse["\$id"],
        Color(int.parse(dbResponse["color"].substring(1, 7), radix: 16) +
            0xFF000000));

    primaryColor = user.color;
  });
  }

}

getSemesters() async {
  lessonList = [];
  print(user.gradeType);

  choosenSemester = user.choosenSemester;

  Future result = database.listDocuments(
    filters: [
      "uid=${user.id}",
    ],
    collectionId: collectionSemester,
  );

  result.then((response) {
    response = jsonDecode(response.toString())["documents"][0]["semesters"];

    print(response);
    bool _error = false;
    int index = -1;

    while (_error == false) {
      index++;
      String id;

      try {
        id = response[index]["\$id"];
      } catch (e) {
        _error = true;
        index = -1;
      }
      if (id != null) {
        lessonList.add(Lesson(
            response[index]["\$id"],
            response[index]["name"],
            response[index]["emoji"],
            double.parse(response[index]["average"].toString())));
        print(lessonList.length);
      }
    }
  }).catchError((error) {
    print(error);
  });
}

Future internetConnection() async {
  bool connected;
  try {
    final result = await InternetAddress.lookup('aw.cloud.eliasschneider.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      connected = true;
    }
  } on SocketException catch (_) {
    connected = false;
  }

  return connected;
}

Future listDocuments(
    {@required String collection,
    @required String name,
    List filters,
    String orderField}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var response;
  if (await internetConnection()) {
    Future result = database.listDocuments(
      filters: filters ?? [],
      collectionId: collection,
    );

    await result.then((r) async {
      response = r.toString();

      await prefs.setString(name, response);
    }).catchError((error) {});
  } else {
    response = prefs.getString(name);
  }

  return response;
}

Future<bool> reAuthenticate(
    {@required String email, @required String password}) async {
  bool success = false;

  Future result = account.createSession(email: email, password: password);

  await result.then((response) {
    print(response);
    success = true;
  }).catchError((error) {
    print(error.message);
    success = false;
  });

  return success;
}

darkModeColorChanger(context) {
  var brightness = MediaQuery.of(context).platformBrightness;
  if (brightness == Brightness.dark) {
    darkmode = true;
    bwColor = Colors.grey[850];
    wbColor = Colors.white;
    defaultBGColor = Colors.grey[900];
  } else {
    darkmode = false;
    bwColor = Colors.white;
    wbColor = Colors.grey[850];
    defaultBGColor = Color(0xFFE5E8F2);
  }
}

noNetworkDialog(context) async {
  if (!await internetConnection()) {
    errorSuccessDialog(
        context: context,
        error: true,
        title: "network_needed_title".tr(),
        text: "network_needed_text".tr());
  }
}

Future sharedPrefs() async {
  prefs = await SharedPreferences.getInstance();
}
