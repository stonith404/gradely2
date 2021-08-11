import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/shared/CLASSES.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

//get info of current logged in user

Future getUserInfo() async {
  var accountResponse;
  bool missingScope = false;

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (await internetConnection()) {
    Future accountResult = account.get();

    await accountResult.then((r) async {
      accountResponse = r.toString();

      await prefs.setString("accountResult", accountResponse);
    }).catchError((error) {
      if (error.code == 401) {
        missingScope = true;
      }
    });
  } else {
    accountResponse = prefs.getString("accountResult");
  }

  accountResponse = jsonDecode(accountResponse.toString());

  if (missingScope) {
    prefs.setBool("signedIn", false);
  } else {
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
  return "done";
}



//checks if client is connected to the server

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

//get documents from the db or from the cache

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

//re authenticates the user

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

//checks if darkmode is activated and changes colors

darkModeColorChanger(context) {
  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    darkmode = true;
    brightness = "dark";
    bwColor = Color(0xFF1d1c1e);
    wbColor = Colors.white;
    defaultBGColor = Color(0xFF010001);
  } else {
    darkmode = false;
    brightness = "light";
    bwColor = Colors.white;
    wbColor = Colors.grey[850];
    defaultBGColor = Color(0xFFF2F2F7);
  }
}

//if there is no connection, show a dialog

noNetworkDialog(context) async {
  if (!await internetConnection()) {
    errorSuccessDialog(
        context: context,
        error: true,
        title: "network_needed_title".tr(),
        text: "network_needed_text".tr());
  }
}

//reads data from the cache

Future sharedPrefs() async {
  prefs = await SharedPreferences.getInstance();
}

//convertes average to pluspoints

getPluspoints(num value) {
  double plusPoints;

  if (value >= 5.75) {
    plusPoints = 2;
  } else if (value >= 5.25) {
    plusPoints = 1.5;
  } else if (value >= 4.75) {
    plusPoints = 1;
  } else if (value >= 4.25) {
    plusPoints = 0.5;
  } else if (value >= 3.75) {
    plusPoints = 0;
  } else if (value >= 3.25) {
    plusPoints = -1;
  } else if (value >= 2.75) {
    plusPoints = -2;
  } else if (value >= 2.25) {
    plusPoints = -3;
  } else if (value >= 1.75) {
    plusPoints = -4;
  } else if (value >= 1.25) {
    plusPoints = -5;
  } else if (value >= 1) {
    plusPoints = -6;
  } else if (value == -99) {
    plusPoints = 0;
  } else if (value.isNaN) {
    plusPoints = 0;
  }
  return plusPoints;
}

//formats the date to the supported date

formatDateForDB(date) {
  try {
    var _formatted = DateTime.parse(date.toString());
    print(_formatted.month.toString().length);
    return "${_formatted.year}.${(() {
      if ((_formatted.month).toString().length == 1) {
        return NumberFormat("00").format(_formatted.month);
      } else {
        return _formatted.month;
      }
    }())}.${(() {
      if ((_formatted.day).toString().length == 1) {
        return NumberFormat("00").format(_formatted.day);
      } else {
        return _formatted.day;
      }
    }())}";
  } catch (_) {
    return "${date.substring(6, 10)}.${date.substring(3, 5)}.${date.substring(0, 2)}";
  }
}

formatDateForClient(date) {
  if (date == "-") {
    return "-";
  } else {
    try {
      var _formatted = DateTime.parse(date.toString());
      print(_formatted.month.toString().length);
      return "${(() {
        if ((_formatted.day).toString().length == 1) {
          return NumberFormat("00").format(_formatted.day);
        } else {
          return _formatted.day;
        }
      }())}.${(() {
        if ((_formatted.month).toString().length == 1) {
          return NumberFormat("00").format(_formatted.month);
        } else {
          return _formatted.month;
        }
      }())}.${_formatted.year}";
    } catch (_) {
      return "${date.substring(8, 10)}.${date.substring(5, 7)}.${date.substring(0, 4)}";
    }
  }
}
//launch url with the package "url launcher"

void launchURL(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
