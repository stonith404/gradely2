import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/shared/CLASSES.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'data.dart';
import 'auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared/defaultWidgets.dart';
import 'main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

bool isChecked = false;
String choosenSemester;
String selectedSemester;

class ChooseSemester extends StatefulWidget {
  @override
  _ChooseSemesterState createState() => _ChooseSemesterState();
}

class _ChooseSemesterState extends State<ChooseSemester> {
  _getSemesters() async {
    semesterList = [];
    var response;

    response = await listDocuments(
        collection: collectionUser,
        name: "semesterList",
        filters: ["uid=${user.id}"]);
    print(response);
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
        setState(() {
          semesterList.add(Semester(
            response[index]["\$id"],
            response[index]["name"],
          ));
        });
      }
    }
  }

  saveChoosenSemester(String _choosenSemester) {
    database.updateDocument(
        collectionId: collectionUser,
        documentId: user.dbID,
        data: {"choosenSemester": _choosenSemester});
  }

  @override
  void initState() {
    super.initState();
    _getSemesters();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: defaultRoundedCorners(),
        backgroundColor: primaryColor,
        title: Text("Semester"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeWrapper()),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddSemester()),
            );
          }),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: semesterList.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: IconSlideAction(
                          color: primaryColor,
                          iconWidget: Icon(
                            FontAwesome5Solid.pencil_alt,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateSemester()),
                            );

                            selectedSemester = semesterList[index].id;
                          },
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: IconSlideAction(
                          color: primaryColor,
                          iconWidget: Icon(
                            FontAwesome5.trash_alt,
                            color: Colors.white,
                          ),
                          onTap: () {
                            return gradelyDialog(
                              context: context,
                              title: "Achtung".tr(),
                              text:
                                  '${'Bist du sicher, dass du'.tr()} "${semesterList[index].name}" ${'löschen willst?'.tr()}',
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    "Nein".tr(),
                                    style: TextStyle(color: wbColor),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    "Löschen".tr(),
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection(
                                            'userData/${auth.currentUser.uid}/semester/')
                                        .doc(semesterList[index].id)
                                        .set({});
                                    FirebaseFirestore.instance
                                        .collection(
                                            'userData/${auth.currentUser.uid}/semester/')
                                        .doc(semesterList[index].id)
                                        .delete();
                                    HapticFeedback.heavyImpact();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChooseSemester()),
                                      (Route<dynamic> route) => false,
                                    );

                                    selectedSemester = semesterList[index].id;
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                    child: Container(
                      decoration: boxDec(),
                      child: ListTile(
                        title: Text(
                          semesterList[index].name,
                        ),
                        trailing: IconButton(
                            color: primaryColor,
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () {
                              choosenSemester = semesterList[index].id;
                              choosenSemesterName = semesterList[index].name;
                              saveChoosenSemester(choosenSemester);
                              HapticFeedback.mediumImpact();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeWrapper()),
                                (Route<dynamic> route) => false,
                              );
                            }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateSemester extends StatefulWidget {
  @override
  _UpdateSemesterState createState() => _UpdateSemesterState();
}

class _UpdateSemesterState extends State<UpdateSemester> {
  @override
  void initState() {
    super.initState();
    renameSemesterController.text = choosenSemesterName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("renameSemester".tr()),
        shape: defaultRoundedCorners(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: renameSemesterController,
                textAlign: TextAlign.left,
                inputFormatters: [emojiRegex()],
                decoration: inputDec("Semester Name")),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: primaryColor, // background
              ),
              child: Text("unbenennen".tr()),
              onPressed: () {
                updateSemesterF(renameSemesterController.text);
                HapticFeedback.mediumImpact();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ChooseSemester()),
                  (Route<dynamic> route) => false,
                );

                renameSemesterController.text = "";
                semesterList = [];
              },
            ),
          ],
        ),
      ),
    );
  }
}

updateSemesterF(String lessonUpdate) {
  FirebaseFirestore.instance
      .collection('userData')
      .doc(auth.currentUser.uid)
      .collection('semester')
      .doc(selectedSemester)
      .update({"name": lessonUpdate});
}

class AddSemester extends StatefulWidget {
  @override
  _AddSemesterState createState() => _AddSemesterState();
}

class _AddSemesterState extends State<AddSemester> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Semester hinzufügen".tr()),
        shape: defaultRoundedCorners(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                inputFormatters: [emojiRegex()],
                controller: addSemesterController,
                textAlign: TextAlign.left,
                decoration: inputDec("Semester Name")),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: primaryColor, // background
              ),
              child: Text("hinzufügen".tr()),
              onPressed: () {
                createSemester(addSemesterController.text);
                HapticFeedback.mediumImpact();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ChooseSemester()),
                  (Route<dynamic> route) => false,
                );

                addLessonController.text = "";
                semesterList = [];
              },
            ),
          ],
        ),
      ),
    );
  }
}

createSemester(String semesterName) async {
  await getUserInfo();
  database.createDocument(
      collectionId: collectionSemester,
      parentDocument: user.dbID,
      parentProperty: "semesters",
      parentPropertyType: "append",
      data: {"name": semesterName});
}
