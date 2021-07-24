import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gradely/chooseSemester.dart';
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
            dbResponse["\$id"]);

        userSignedIn = true;
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
    {@required String collection, @required String name, List filters}) async {
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
