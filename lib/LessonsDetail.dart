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

String selectedTest = "";
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
                  return ListTile(
                      title: Text(testList[index]),
                      subtitle: Row(
                        children: [
                          Text((averageList[index] / averageListWeight[index])
                              .toString()),
                          Text(averageListWeight[index].toString()),
                        ],
                      ),
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
                      });
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                      Text(plusPoints.toString()),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => addTest()),
                            );
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
                  child: Text(
                    testDetails["name"],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ),
                TextField(
                  controller: editTestInfoName,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Lesson Name',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                TextField(
                  controller: editTestInfoGrade,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Lesson Name',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                TextField(
                  controller: editTestInfoWeight,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Lesson Name',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
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
                    child: Text("update")),
                TextButton(
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
                    child: Text("Delete"))
              ],
            ),
          )),
    );
  }
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

class addTest extends StatefulWidget {
  @override
  _addTestState createState() => _addTestState();
}

class _addTestState extends State<addTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('neuer Test'),
        shape: defaultRoundedCorners(),
      ),
      backgroundColor: Colors.white.withOpacity(
          0.85), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: addTestNameController,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter TestName',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextField(
            controller: addTestGradeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter TestGrade',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextField(
            controller: addTestWeightController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter TestWeight',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            child: Text("add"),
            onPressed: () {
              bool isNumeric() {
                if (addTestGradeController.text == null) {
                  return false;
                }
                return double.tryParse(addTestGradeController.text) != null;
              }

              if (isNumeric() == false) {
                setState(() {
                  errorMessage = "Bitte eine gültige Note eingeben.";
                });
                Future.delayed(Duration(seconds: 4)).then((value) => {
                      setState(() {
                        errorMessage = "";
                      })
                    });
              }

              createTest(
                addTestNameController.text,
                double.parse(addTestGradeController.text),
                double.parse(addTestWeightController.text),
              );
              setState(() {
                addLessonController.text = "";
                courseList = [];
              });

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LessonsDetail()),
              );
            },
          ),
          Text(errorMessage)
        ],
      ),
    );
  }
}
