import 'package:flutter/services.dart';

import 'main.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userAuth/login.dart';
import 'test.dart';
import 'testDetail.dart';
import 'data.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

String selectedTest = "";
String errorMessage = "";
double averageOfTests;
List testListID = [];
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();

class LessonsDetail extends StatefulWidget {
  @override
  _LessonsDetailState createState() => _LessonsDetailState();
}

class _LessonsDetailState extends State<LessonsDetail> {
  getTests() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(
            'grades/${auth.currentUser.uid}/grades/$selectedLesson/grades')
        .get();
    List<DocumentSnapshot> documents = result.docs;
    setState(() {
      testList = [];
      documents.forEach((data) => testListID.add(data.id));
      documents.forEach((data) => testList.add(data["name"]));
      print(testList);
    });

    print(testList);
  }

  List averageList = [];
  getTestAvarage() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(
            'grades/${auth.currentUser.uid}/grades/$selectedLesson/grades')
        .get();

    List<DocumentSnapshot> documents = result.docs;
    setState(() {
      averageList = [];
      documents.forEach((data) => averageList.add(data["grade"]));
    });

    num sum = 0;
    num anzahl = 0;

    for (num e in averageList) {
      sum += e;
      anzahl = anzahl + 1;
    }

    averageOfTests = sum / anzahl;

    FirebaseFirestore.instance
        .collection('grades')
        .doc(auth.currentUser.uid)
        .collection("grades")
        .doc(selectedLesson)
        .update({"average": averageOfTests});
  }

  void initState() {
    super.initState();
    getTests();
    getTestAvarage();
  }

  @override
  Widget build(BuildContext context) {
    getPluspoints();

    return Scaffold(
        floatingActionButton: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => addTest()),
              );
            }),
        appBar: AppBar(
          title: Text(selectedLessonName),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: testList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      title: Text(testList[index]),
                      subtitle: Text(averageList[index].toString()),
                      onTap: () async {
                        setState(() {
                          selectedTest = testListID[index];
                        });
                        testDetails = (await FirebaseFirestore.instance
                                .collection(
                                    "grades/${auth.currentUser.uid}/grades/$selectedLesson/grades/")
                                .doc(selectedTest)
                                .get())
                            .data();

                        setState(() {
                          testDetails = testDetails;
                        });

                        testDetail(context);
                      });
                },
              ),
            ),
            Container(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                child: Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Column(
                      children: [
                        Text(averageOfTests.toStringAsFixed(2)),
                        Text(plusPoints.toString()),
                     
                      ],
                    ),
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
                              'grades/${auth.currentUser.uid}/grades/$selectedLesson/grades')
                          .doc(selectedTest)
                          .set({
                        "name": editTestInfoName.text,
                        "grade": double.parse(
                          editTestInfoGrade.text,
                        ),
                        "weight:": double.parse(editTestInfoGrade.text)
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
                    TextButton(onPressed: (){
     FirebaseFirestore.instance
                          .collection(
                              'grades/${auth.currentUser.uid}/grades/$selectedLesson/grades')
                          .doc(selectedTest)
                          .set({});
                                  FirebaseFirestore.instance
                                     .collection(
                              'grades/${auth.currentUser.uid}/grades/$selectedLesson/grades')
                          .doc(selectedTest)
                                      .delete();

                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                              LessonsDetail(),
                                      transitionDuration: Duration(seconds: 0),
                                    ),
                                  );
                    }, child: Text("Delete"))
              ],
            ),
          )),
    );
  }
}

createTest(String testName, double grade, double weight) {
  FirebaseFirestore.instance
      .collection('grades')
      .doc(auth.currentUser.uid)
      .collection("grades")
      .doc(selectedLesson)
      .collection("grades")
      .doc(testName)
      .set({"name": testName, "grade": grade, "weight:": weight});
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
        title: Text("add"),
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
