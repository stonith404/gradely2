import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'package:gradely/screens/main/chooseSemester.dart';
import 'package:gradely/shared/CLASSES.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> getUserInfo() async {
  bool userSignedIn;

  try {
    Future accountResult = account.get();

    await accountResult.then((accountResponse) async {
      accountResponse = jsonDecode(accountResponse.toString());
      Future dbResult = database.listDocuments(
          collectionId: collectionUser,
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

        userSignedIn = true;

        primaryColor = user.color;
      }).catchError((error) {});
    });
  } catch (_) {
    userSignedIn = false;
  }
  return userSignedIn;
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
      orderField:  orderField,
   
   
      orderType: "ASC",
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


//text controllers


TextEditingController addLessonController = new TextEditingController();
TextEditingController changeEmailController = new TextEditingController();
TextEditingController changeDisplayName = new TextEditingController();
TextEditingController addSemesterController = new TextEditingController();
TextEditingController renameTestWeightController = new TextEditingController();
TextEditingController renameSemesterController = new TextEditingController();
TextEditingController addGradeNameController = new TextEditingController();
TextEditingController addGradeGradeController = new TextEditingController();
TextEditingController addTestNameController = new TextEditingController();
TextEditingController addTestGradeController = new TextEditingController();
TextEditingController addTestWeightController = new TextEditingController();
TextEditingController addTestDateController = new TextEditingController();
TextEditingController editTestDateController = new TextEditingController();
TextEditingController contactMessage = new TextEditingController();
TextEditingController dreamGradeGrade = new TextEditingController();
TextEditingController dreamGradeWeight = new TextEditingController();
TextEditingController passwordController = new TextEditingController();
TextEditingController passwordPlaceholder = new TextEditingController();
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();