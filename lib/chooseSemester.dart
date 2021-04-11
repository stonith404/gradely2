import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'userAuth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared/defaultWidgets.dart';
import 'main.dart';
import 'package:easy_localization/easy_localization.dart';

bool isChecked = false;
String choosenSemester;
String selectedSemester;
var semesterListID = [];
var semesterList = [];

class chooseSemester extends StatefulWidget {
  @override
  _chooseSemesterState createState() => _chooseSemesterState();
}

class _chooseSemesterState extends State<chooseSemester> {
  _getSemesters() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('userData/${auth.currentUser.uid}/semester')
        .get();
    List<DocumentSnapshot> documents = result.docs;

    semesterListID = [];
    semesterList = [];

    documents.forEach((data) => semesterList.add(data["name"]));
    documents.forEach((data) => semesterListID.add(data.id));

    setState(() {
      semesterListID = semesterListID;
      semesterList = semesterList;
    });
  }

  saveChoosenSemester(String _choosenSemester, _choosenSemesterName) {
    print(choosenSemester);
    FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .update({
      "choosenSemester": _choosenSemester,
      "choosenSemesterName": _choosenSemesterName
    });
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
    _getSemesters();
    return Scaffold(
      appBar: AppBar(
        title: Text("Semester"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
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
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => addSemester()),
            );
          }),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: semesterListID.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'unbenennen'.tr(),
                          color: Colors.black45,
                          icon: Icons.edit,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => updateSemester()),
                            );

                            selectedSemester = semesterListID[index];
                          },
                        ),
                        IconSlideAction(
                          caption: 'löschen'.tr(),
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Achtung".tr()),
                                    content: Text(
                                        "${'Bist du sicher, dass du'.tr()} ${semesterList[index]} ${'löschen willst?'.tr()}"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Nein".tr()),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text("Löschen".tr()),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection(
                                                  'userData/${auth.currentUser.uid}/semester/')
                                              .doc(semesterListID[index])
                                              .set({});
                                          FirebaseFirestore.instance
                                              .collection(
                                                  'userData/${auth.currentUser.uid}/semester/')
                                              .doc(semesterListID[index])
                                              .delete();

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    chooseSemester()),
                                            (Route<dynamic> route) => false,
                                          );

                                          selectedSemester =
                                              semesterListID[index];
                                        },
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                      child: Container(
                        decoration: boxDec(),
                        child: ListTile(
                          title: Text(
                            semesterList[index],
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                choosenSemester = semesterListID[index];
                                choosenSemesterName = semesterList[index];
                                saveChoosenSemester(
                                    choosenSemester, choosenSemesterName);
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

class updateSemester extends StatefulWidget {
  @override
  _updateSemesterState createState() => _updateSemesterState();
}

class _updateSemesterState extends State<updateSemester> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Semester ${'unbenennen'.tr()}"),
        shape: defaultRoundedCorners(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                style: TextStyle(color: Colors.black),
                controller: renameSemesterController,
                textAlign: TextAlign.left,
                decoration: inputDec("Semester Name")),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              child: Text("unbenennen".tr()),
              onPressed: () {
                updateSemesterF(renameSemesterController.text);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => chooseSemester()),
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

class addSemester extends StatefulWidget {
  @override
  _addSemesterState createState() => _addSemesterState();
}

class _addSemesterState extends State<addSemester> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Semester hinzufügen".tr()),
        shape: defaultRoundedCorners(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(21.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                style: TextStyle(color: Colors.black),
                controller: addSemesterController,
                textAlign: TextAlign.left,
                decoration: inputDec("Semester Name")),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text("hinzufügen".tr()),
              onPressed: () {
                createSemester(addSemesterController.text);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => chooseSemester()),
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

createSemester(String semesterName) {
  CollectionReference gradesCollection = FirebaseFirestore.instance
      .collection('userData/${auth.currentUser.uid}/semester/');
  gradesCollection.doc().set(
    {"name": semesterName},
  );
}
