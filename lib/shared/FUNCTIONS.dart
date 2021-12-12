import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely2/shared/CLASSES.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
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
  } else if (accountResponse != null) {
    var dbResponse = (await api.listDocuments(
        name: "userDB",
        collection: collectionUser,
        filters: ["uid=${accountResponse['\$id']}"]))["documents"][0];

    user = User(
      accountResponse['\$id'],
      accountResponse['name'],
      accountResponse['registration'],
      accountResponse['status'],
      accountResponse['passwordUpdate'],
      accountResponse['email'],
      accountResponse['emailVerification'],
      dbResponse["gradeType"],
      dbResponse["choosenSemester"],
      dbResponse["\$id"],
    );
  }

  return "done";
}

//checks if client is connected to the server

Future internetConnection({BuildContext context}) async {
  if (kIsWeb) {
    return true;
  } else {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      errorSuccessDialog(
          context: context,
          error: true,
          text: "no_network".tr(),
          title: "network_needed_title".tr());
      return false;
    }
  }
}

isMaintenance() async {
  try {
    var request = await http
        .get(Uri.parse("https://gradelyapp.com/static-api"))
        .timeout(const Duration(seconds: 2));
    return jsonDecode(request.body)["maintenance"];
  } on TimeoutException catch (_) {
    return false;
  } catch (_) {
    return false;
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

frontColor() {
  Color color;
  if (primaryColor == Color(0xFFFFFFFF)) {
    color = Colors.black;
  } else {
    color = color = Colors.white;
  }
  return color;
}

//checks if darkmode is activated and changes colors

darkModeColorChanger(context) {
  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    if (primaryColor == Color(0xff000000)) {
      primaryColor = Colors.white;
    }
    darkmode = true;
    brightness = "dark";
    bwColor = Color(0xFF1d1c1e);
    wbColor = Colors.white;
    defaultBGColor = Color(0xFF010001);
  } else {
    if (primaryColor == Color(0xffffffff)) {
      primaryColor = Colors.black;
    }
    darkmode = false;
    brightness = "light";
    bwColor = Colors.white;
    wbColor = Colors.grey[850];
    defaultBGColor = Color(0xFFF2F2F7);
  }
  appBarTextTheme = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
    fontFamily: "PlayfairDisplay",
  );
  title = TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
      fontFamily: "PlayfairDisplay",
      fontSize: 21);
  bigTitle = TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
      fontFamily: "PlayfairDisplay",
      fontSize: 30);
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
  if (date == "") {
    return "-";
  } else {
    try {
      var _formatted = DateTime.parse(date.toString());
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

void launchURL(_url) async => await launch(_url);

//clears all variables when user sign out
clearVariables() {
  prefs.clear();
  gradeList = [];
  semesterList = [];
  lessonList = [];
}

//changes email of user

changeEmail(_email, context) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          title: Text("action_required".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("re_enter_password_save_changes".tr()),
              SizedBox(
                height: 20,
              ),
              TextField(
                  controller: passwordController,
                  textAlign: TextAlign.left,
                  obscureText: true,
                  decoration: inputDec(label: "your_password".tr())),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("done".tr()),
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
                      text: "email_updated".tr());

                  Future.delayed(Duration(seconds: 2));
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "subjects",
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print(e.message);
                  Navigator.of(context).pop();
                  errorSuccessDialog(
                      context: context, error: true, text: e.message);
                }
                passwordController.text = "";
              },
            ),
          ],
        );
      });
}

signOut() async {
  await account.deleteSession(sessionId: "current");
  prefs.setBool("signedIn", false);

  clearVariables();
}

completeOfflineTasks(context) {
  List tasks = [
    // {
    //   "type": "create",
    //   "documentId": "",
    //   "collection": collectionGrades,
    //   "data": {"name": "off", "grade": 3.3, "weight": 1.0}
    // }
  ];

  if (tasks.isNotEmpty) {
    try {
      for (var item in tasks) {
        if (item["type"] == "update") {
          api.updateDocument(context,
              collectionId: item["collection"],
              documentId: item["documentId"],
              data: item["data"]);
        } else if (item["type"] == "create") {
          api.createDocument(context,
              collectionId: item["collection"], data: item["data"]);
        } else if (item["type"] == "delete") {
          api.deleteDocument(
            context,
            collectionId: item["collection"],
            documentId: item["documentId"],
          );
        }
      }

      errorSuccessDialog(context: context, error: false, text: "Uploaded");
    } catch (e) {
      print(e);
    }
  }
  print("no offline tasks");
}

// ignore: non_constant_identifier_names
GradelyPageRoute({Widget Function(BuildContext) builder}) {
  if (Platform.isIOS) {
    return MaterialWithModalsPageRoute(builder: builder);
  } else {
    return MaterialPageRoute(builder: builder);
  }
}

getUserAgent() {
  String platform;
  if (Platform.isIOS) {
    platform = "iPhone OS";
  } else if (Platform.isAndroid) {
    platform = "Android";
  } else if (Platform.isMacOS) {
    platform = "Mac OS X";
  } else if (Platform.isWindows) {
    platform = "Windows";
  }

  return "Mozilla/5.0 ($platform, Firefox)";
}

String roundGrade(double value, double x) {
  if (x == 0.1) {
    return value.toStringAsFixed(1);
  } else if (x == 1) {
    return value.roundToDouble().toString();
  } else if (x == 0.5) {
    return ((value * 2).round() / 2).toString();
  } else {
    return value.toStringAsFixed(2);
  }
}
