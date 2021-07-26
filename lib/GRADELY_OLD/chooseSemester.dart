import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/GRADELY_OLD/shared/VARIABLES..dart';
import 'package:gradely/GRADELY_OLD/LessonsDetail.dart';
import 'package:gradely/GRADELY_OLD/data.dart';
import 'package:gradely/GRADELY_OLD/userAuth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/GRADELY_OLD/shared/defaultWidgets.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

bool isChecked = false;
String choosenSemester;
String selectedSemester;
var semesterListID = [];
var semesterList = [];

class ChooseSemester extends StatefulWidget {
  @override
  _ChooseSemesterState createState() => _ChooseSemesterState();
}

class _ChooseSemesterState extends State<ChooseSemester> {
  _getSemesters() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('userData/${auth.currentUser.uid}/semester')
        .orderBy("name")
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
              itemCount: semesterListID.length,
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

                            selectedSemester = semesterListID[index];
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
                                  '${'Bist du sicher, dass du'.tr()} "${semesterList[index]}" ${'löschen willst?'.tr()}',
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
                                        .doc(semesterListID[index])
                                        .set({});
                                    FirebaseFirestore.instance
                                        .collection(
                                            'userData/${auth.currentUser.uid}/semester/')
                                        .doc(semesterListID[index])
                                        .delete();
                                    HapticFeedback.heavyImpact();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChooseSemester()),
                                      (Route<dynamic> route) => false,
                                    );

                                    selectedSemester = semesterListID[index];
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
                          semesterList[index],
                        ),
                        trailing: IconButton(
                            color: primaryColor,
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () {
                              choosenSemester = semesterListID[index];
                              choosenSemesterName = semesterList[index];
                              saveChoosenSemester(
                                  choosenSemester, choosenSemesterName);
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
                inputFormatters: [EmojiRegex()],
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
                inputFormatters: [EmojiRegex()],
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

createSemester(String semesterName) {
  CollectionReference gradesCollection = FirebaseFirestore.instance
      .collection('userData/${auth.currentUser.uid}/semester/');
  gradesCollection.doc().set(
    {"name": semesterName},
  );
}
