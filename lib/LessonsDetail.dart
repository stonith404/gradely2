import 'package:flutter/services.dart';

import 'main.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userAuth/login.dart';
import 'chooseSemester.dart';
import 'data.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'shared/defaultWidgets.dart';
import 'dart:async';

String selectedTest = "selectedTest";
String errorMessage = "";
double averageOfTests = 0;
List testListID = [];
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();

class LessonsDetail extends StatefulWidget {
  @override
  _LessonsDetailState createState() => _LessonsDetailState();
}

class _LessonsDetailState extends State<LessonsDetail> {
  _getTests() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(
            'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
        .get();
    List<DocumentSnapshot> documents = result.docs;
    setState(() {
      testList = [];
      testListID = [];
      documents.forEach((data) => testListID.add(data.id));
      documents.forEach((data) => testList.add(data["name"]));
    });
  }

  darkModeColorChanger() {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      setState(() {
        bwColor = Colors.black;
        wbColor = Colors.white;
      });
    } else {
      bwColor = Colors.white;
      wbColor = Colors.black;
    }
  }

  List averageList = [];
  List averageListWeight = [];
  getTestAvarage() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(
            'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
        .get();

    List<DocumentSnapshot> documents = result.docs;
    setState(() {
      averageList = [];
      documents.forEach((data) {
        double _averageSum;

        _averageSum = data["grade"] * data["weight"];
        averageList.add(_averageSum);
        averageListWeight.add(data["weight"]);
      });
    });

    num _sumW = 0;
    num _sum = 0;

    for (num e in averageListWeight) {
      _sumW += e;
    }

    for (num e in averageList) {
      _sum += e;
    }
    setState(() {
      averageOfTests = _sum / _sumW;
    });

    FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .collection('semester')
        .doc(choosenSemester)
        .collection('lessons')
        .doc(selectedLesson)
        .update({"average": averageOfTests});
  }

  void initState() {
    super.initState();

    getChoosenSemester();
    _getTests();
    getTestAvarage();

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      darkModeColorChanger();
    });
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    getPluspoints(averageOfTests);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
             
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
          title: Text(selectedLessonName),
          shape: defaultRoundedCorners(),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: testList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                    child: Container(
                      decoration: boxDec(),
                      child: ListTile(
                          title: Text(testList[index]),
                          subtitle: averageList.isEmpty
                              ? Text("")
                              : Row(
                                  children: [
                                    Text("Gewichtung:"),
                                    Text(averageListWeight[index].toString()),
                                  ],
                                ),
                          trailing: Text(
                              (averageList[index] / averageListWeight[index])
                                  .toString()),
                          onTap: () async {
                            _getTests();

                            selectedTest = testListID[index];

                            testDetails = (await FirebaseFirestore.instance
                                    .collection(
                                        "userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades")
                                    .doc(selectedTest)
                                    .get())
                                .data();

                            testDetail(context);
                          }),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: bwColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(() {
                        if (gradesResult == "Pluspunkte") {
                          return plusPoints.toString();
                        } else {
                          return "";
                        }
                      }()),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            addTest(context);
                          }),
                      Text((() {
                        if (averageOfTests.isNaN) {
                          return "-";
                        } else {
                          return averageOfTests.toStringAsFixed(2);
                        }
                      })()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future testDetail(BuildContext context) {
    editTestInfoGrade.text = testDetails["grade"].toString();
    editTestInfoName.text = testDetails["name"];
    editTestInfoWeight.text = testDetails["weight"].toString();
    return showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (context) => SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                    child: Text(
                      testDetails["name"],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(
                      thickness: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editTestInfoName,
                      textAlign: TextAlign.left,
                      decoration: inputDec("Test Name"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editTestInfoGrade,
                      textAlign: TextAlign.left,
                      decoration: inputDec("Gewichtung"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editTestInfoWeight,
                      textAlign: TextAlign.left,
                      decoration: inputDec("Gewichtung"),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection(
                                'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
                            .doc(selectedTest)
                            .set({
                          "name": editTestInfoName.text,
                          "grade": double.parse(
                            editTestInfoGrade.text,
                          ),
                          "weight": double.parse(editTestInfoWeight.text)
                        });
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                LessonsDetail(),
                            transitionDuration: Duration(seconds: 0),
                          ),
                        );
                      },
                      child: Text("Test updaten")),
                  ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection(
                                'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
                            .doc(selectedTest)
                            .set({});
                        FirebaseFirestore.instance
                            .collection(
                                'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
                            .doc(selectedTest)
                            .delete();

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                LessonsDetail(),
                            transitionDuration: Duration(seconds: 0),
                          ),
                        );
                      },
                      child: Text("Test löschen"))
                ],
              ),
            ),
          )),
    );
  }
}

Future addTest(BuildContext context) {
  addTestNameController.text = "";
  addTestGradeController.text = "";
  addTestWeightController.text = "1";

  return showCupertinoModalBottomSheet(
    expand: true,
    context: context,
    builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Material(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                    child: Text(
                      "Test hinzufügen",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(
                      thickness: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: addTestNameController,
                        textAlign: TextAlign.left,
                        decoration: inputDec("Name")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: addTestGradeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        decoration: inputDec("Note")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: addTestWeightController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        decoration: inputDec("Gewichtung")),
                  ),
                  ElevatedButton(
                    child: Text("hinzufügen"),
                    onPressed: () {
                      bool isNumeric() {
                        if (addTestGradeController.text == null) {
                          return false;
                        }
                        return double.tryParse(addTestGradeController.text) !=
                            null;
                      }

                      if (isNumeric() == false) {
                        errorMessage = "Bitte eine gültige Note eingeben.";

                        Future.delayed(Duration(seconds: 4))
                            .then((value) => {errorMessage = ""});
                      }

                      createTest(
                        addTestNameController.text,
                        double.parse(addTestGradeController.text),
                        double.parse(addTestWeightController.text),
                      );

                      addLessonController.text = "";
                      courseList = [];

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LessonsDetail()),
                      );
                    },
                  ),
                  Text(errorMessage)
                ],
              )),
        )),
  );
}

createTest(String testName, double grade, double weight) {
  FirebaseFirestore.instance
      .collection('userData')
      .doc(auth.currentUser.uid)
      .collection('semester')
      .doc(choosenSemester)
      .collection('lessons')
      .doc(selectedLesson)
      .collection('grades')
      .doc()
      .set({"name": testName, "grade": grade, "weight": weight});
}
