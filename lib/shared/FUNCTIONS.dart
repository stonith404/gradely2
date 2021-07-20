import 'dart:convert';

import 'package:gradely/chooseSemester.dart';
import 'package:gradely/shared/CLASSES.dart';
import 'package:gradely/shared/VARIABLES..dart';

Future<bool> getUserInfo() async {
  bool userSignedIn;
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
          dbResponse["choosenSemester"]);

      userSignedIn = true;
    }).catchError((error) {
      userSignedIn = false;
    });
  });

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
