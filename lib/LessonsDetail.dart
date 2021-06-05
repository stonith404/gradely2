import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/shared/loading.dart';
import 'package:gradely/statistics.dart';
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
import 'package:gradely/semesterDetail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool buttonDisabled = false;
String selectedTest = "selectedTest";
String errorMessage = "";
double averageOfTests = 0;
List<String> testListID = [];
List<String> dateList = [];
List<num> averageList = [];
List<num> averageListWeight = [];
num _sumW = 0;
num _sum = 0;
var defaultBGColor;
double _buttonRotation = 360;
Timer timer;

var selectedDate = DateTime.now();
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();

class LessonsDetail extends StatefulWidget {
  @override
  _LessonsDetailState createState() => _LessonsDetailState();
}

class _LessonsDetailState extends State<LessonsDetail> {
  getTests([bool cache]) async {
    if (cache == null) {
      cache = false;
    }
    QuerySnapshot result;

    result = await FirebaseFirestore.instance
        .collection(
            'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
        .orderBy("date", descending: false)
        .get(cache
            ? GetOptions(source: Source.cache)
            : GetOptions(source: Source.serverAndCache));

    List<DocumentSnapshot> documents = result.docs;
    testList = [];
    testListID = [];
    dateList = [];
    averageList = [];
    averageListWeight = [];

    setState(() {
      documents.forEach((data) {
        try {
          if (data["date"] == "") {
            FirebaseFirestore.instance
                .collection(
                    'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
                .doc(data.id)
                .update({"date": "-"});
          }
        } catch (e) {
          //if null
          FirebaseFirestore.instance
              .collection(
                  'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
              .doc(data.id)
              .update({"date": "-"});
        }
      });
      documents.forEach((data) {
        num _averageSum;

        _averageSum = data["grade"] * data["weight"];

        averageList.add(_averageSum);
        averageListWeight.add(data["weight"]);
        setState(() {
          testListID.add(data.id);
        });
        print(averageList.runtimeType);
        testList.add(data["name"]);

        try {
          if (data["date"] == "") {
            FirebaseFirestore.instance
                .collection(
                    'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
                .doc(data.id)
                .update({"date": "-"});
          } else {
            dateList.add(data["date"]);
          }
        } catch (e) {
          FirebaseFirestore.instance
              .collection(
                  'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
              .doc(data.id)
              .update({"date": "-"});
        }
      });

//this calculates the average of the tests
      _sumW = 0;
      _sum = 0;

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
    });
  }

  darkModeColorChanger() {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      setState(() {
        bwColor = Colors.grey[850];
        wbColor = Colors.white;
        defaultBGColor = Colors.grey[900];
      });
    } else {
      bwColor = Colors.white;
      wbColor = Colors.grey[850];
      defaultBGColor = Colors.grey[300];
    }
  }

  void initState() {
    super.initState();
    getTests(true);
    print(testList.length);
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
    getUIDDocuments();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      testListID = testListID;
      print(testListID.length);
    });
    getPluspoints(averageOfTests);
    darkModeColorChanger();

    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: buttonDisabled
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _buttonRotation = 180;
                          buttonDisabled = true;
                          Timer(Duration(seconds: 20), () {
                            print("mq");
                            setState(() => buttonDisabled = false);
                          });
                        });

                        getTests();
                      },
                icon: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    FontAwesome5Solid.sync,
                    size: 17,
                  ),
                ))
          ],
          backgroundColor: defaultColor,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_outlined,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeWrapper()),
                  (Route<dynamic> route) => false,
                );
                timer.cancel();
              }),
          title: Text(selectedLessonName),
          shape: defaultRoundedCorners(),
        ),
        body: Column(
          children: [
            Expanded(
              child: testListID.length == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "empty1".tr(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("empty2".tr()),
                              Icon(
                                FontAwesome5Solid.sync,
                                size: 15,
                              ),
                              Text("empty3".tr())
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("empty4".tr()),
                              Icon(Icons.add),
                              Text("empty5".tr())
                            ],
                          )
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: testListID.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Container(
                            decoration: boxDec(),
                            child: Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              secondaryActions: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: IconSlideAction(
                                    color: defaultColor,
                                    iconWidget: Icon(
                                      FontAwesome5.trash_alt,
                                      color: Colors.white,
                                    ),
                                    onTap: () {
                                      getTests();

                                      selectedTest = testListID[index];
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
                                      HapticFeedback.mediumImpact();
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              LessonsDetail(),
                                          transitionDuration:
                                              Duration(seconds: 0),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              child: ListTile(
                                  title: Text(
                                    testList[index],
                                  ),
                                  subtitle: averageList.isEmpty
                                      ? Text("")
                                      : Row(
                                          children: [
                                            Icon(
                                              Icons.calculate_outlined,
                                              size: 20,
                                            ),
                                            Text(" " +
                                                averageListWeight[index]
                                                    .toString() +
                                                "   "),
                                            Icon(
                                              Icons.date_range,
                                              size: 20,
                                            ),
                                            Text(" " +
                                                dateList[index].toString()),
                                          ],
                                        ),
                                  trailing: Text(() {
                                    if ((averageList[index] /
                                            averageListWeight[index])
                                        .isNaN) {
                                      return "-";
                                    } else {
                                      return (averageList[index] /
                                              averageListWeight[index])
                                          .toStringAsFixed(2);
                                    }
                                  }()),
                                  onTap: () async {
                                    getTests(true);

                                    selectedTest = testListID[index];

                                    testDetails = (await FirebaseFirestore
                                            .instance
                                            .collection(
                                                "userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades")
                                            .doc(selectedTest)
                                            .get())
                                        .data();

                                    testDetail(context);
                                  }),
                            ),
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
                boxShadow: [],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      gradesResult == "Pluspunkte"
                          ? Column(
                              children: [
                                Text(
                                  plusPoints.toString(),
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  (() {
                                    if (averageOfTests.isNaN) {
                                      return "-";
                                    } else {
                                      return averageOfTests.toStringAsFixed(2);
                                    }
                                  })(),
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 10),
                                ),
                              ],
                            )
                          : Text((() {
                              if (averageOfTests.isNaN) {
                                return "-";
                              } else {
                                return averageOfTests.toStringAsFixed(2);
                              }
                            })(), style: TextStyle(fontSize: 17)),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            addTest(context);
                            HapticFeedback.lightImpact();
                          }),
                      IconButton(
                          icon: Icon(FontAwesome5Solid.calculator, size: 17),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Charts()),
                            );
                            HapticFeedback.lightImpact();
                          }),
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
    if (testDetails["date"].toString() == "null") {
      editTestDateController.text = formatDate(DateTime.now());
    } else {
      editTestDateController.text = testDetails["date"].toString();
    }

    return showCupertinoModalBottomSheet(
      backgroundColor: defaultBGColor,
      expand: true,
      context: context,
      builder: (context) => SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Material(
            color: defaultBGColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: defaultColor,
                        child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection(
                                      'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
                                  .doc(selectedTest)
                                  .set({
                                "name": editTestInfoName.text,
                                "grade": double.parse(
                                  editTestInfoGrade.text.replaceAll(",", "."),
                                ),
                                "weight": double.parse(editTestInfoWeight.text
                                    .replaceAll(",", ".")),
                                "date": editTestDateController.text
                              });
                              HapticFeedback.lightImpact();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LessonsDetail()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            icon: Icon(Icons.edit)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
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
                      decoration: inputDec("Test Name".tr()),
                      inputFormatters: [EmojiRegex()],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2025),
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    onSurface: wbColor,
                                    surface: defaultColor,
                                  ),
                                ),
                                child: child,
                              );
                            });
                        if (picked != null && picked != selectedDate)
                          setState(() {
                            var _formatted = DateTime.parse(picked.toString());
                            editTestDateController.text =
                                "${_formatted.year}.${_formatted.month}." +
                                    (_formatted.day.toString().length > 1
                                        ? _formatted.day.toString()
                                        : "0${_formatted.day}");
                          });
                      },
                      child: AbsorbPointer(
                        child: TextField(
                            controller: editTestDateController,
                            textAlign: TextAlign.left,
                            decoration: inputDec("date".tr())),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editTestInfoGrade,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.left,
                      decoration: inputDec("Note".tr()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editTestInfoWeight,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.left,
                      decoration: inputDec("Gewichtung".tr()),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Future addTest(BuildContext context) {
    addTestNameController.text = "";
    addTestGradeController.text = "";
    addTestDateController.text = "";
    addTestWeightController.text = "1";

    return showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (context) => StatefulBuilder(builder: (BuildContext context,
          StateSetter setState /*You can rename this!*/) {
        return SingleChildScrollView(
            controller: ModalScrollController.of(context),
            child: Material(
              color: defaultBGColor,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: defaultColor,
                            child: IconButton(
                                color: Colors.white,
                                onPressed: () async {
                                  getTests();

                                  bool isNumeric() {
                                    if (addTestGradeController.text == null) {
                                      return false;
                                    }
                                    return double.tryParse(
                                            addTestGradeController.text) !=
                                        null;
                                  }

                                  if (isNumeric() == false) {
                                    setState(() {
                                      errorMessage =
                                          "Bitte eine gültige Note eingeben.";
                                    });

                                    Future.delayed(Duration(seconds: 4))
                                        .then((value) => {errorMessage = ""});
                                  }
                                  await FirebaseFirestore.instance
                                      .collection('userData')
                                      .doc(auth.currentUser.uid)
                                      .collection('semester')
                                      .doc(choosenSemester)
                                      .collection('lessons')
                                      .doc(selectedLesson)
                                      .collection('grades')
                                      .doc()
                                      .set({
                                    "name": addTestNameController.text,
                                    "grade": double.parse(addTestGradeController
                                        .text
                                        .replaceAll(",", ".")),
                                    "weight": double.parse(
                                        addTestWeightController.text
                                            .replaceAll(",", ".")),
                                    "date": addTestDateController.text
                                  });

                                  addLessonController.text = "";

                                  HapticFeedback.lightImpact();
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                              LessonsDetail(),
                                      transitionDuration: Duration(seconds: 0),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
                          "addexam".tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
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
                          decoration: inputDec("Test Name".tr()),
                          inputFormatters: [EmojiRegex()],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2025),
                                builder: (BuildContext context, Widget child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        onSurface: wbColor,
                                        surface: defaultColor,
                                      ),
                                    ),
                                    child: child,
                                  );
                                });

                            if (picked != null && picked != selectedDate)
                              setState(() {
                                var _formatted =
                                    DateTime.parse(picked.toString());
                                addTestDateController.text =
                                    "${_formatted.year}.${_formatted.month}.${_formatted.day}";
                              });
                          },
                          child: AbsorbPointer(
                            child: TextField(
                                controller: addTestDateController,
                                textAlign: TextAlign.left,
                                decoration: inputDec("date".tr())),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                            controller: addTestGradeController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.left,
                            decoration: inputDec("Note".tr())),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                            controller: addTestWeightController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.left,
                            decoration: inputDec("Gewichtung".tr())),
                      ),
                      Text(errorMessage)
                    ],
                  )),
            ));
      }),
    );
  }
}

Future DreamGradeC(BuildContext context) {
  dreamGradeGrade.text = "";
  dreamGradeWeight.text = "1";
  num dreamgradeResult = 0;
  double dreamgrade = 0;
  double dreamgradeWeight = 1;

  return showCupertinoModalBottomSheet(
    expand: true,
    context: context,
    builder: (context) => StatefulBuilder(builder:
        (BuildContext context, StateSetter setState /*You can rename this!*/) {
      getDreamGrade() {
        try {
          setState(() {
            dreamgradeResult =
                ((dreamgrade * (_sumW + dreamgradeWeight) - _sum) /
                    dreamgradeWeight);
          });
        } catch (e) {
          setState(() {
            dreamgradeResult = 0;
          });
        }
      }

      return SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Material(
            color: defaultBGColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("dream grade calculator".tr(),
                          style: TextStyle(fontSize: 25)),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: defaultColor,
                        child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: dreamGradeGrade,
                      onChanged: (String value) async {
                        dreamgrade = double.tryParse(
                            dreamGradeGrade.text.replaceAll(",", "."));
                        getDreamGrade();
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.left,
                      decoration: inputDec("dream grade".tr()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: dreamGradeWeight,
                      onChanged: (String value) async {
                        dreamgradeWeight = double.tryParse(
                            dreamGradeWeight.text.replaceAll(",", "."));
                        getDreamGrade();
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.left,
                      decoration: inputDec("dream grade weight".tr()),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Text("dreamGrade1".tr()),
                      Text((() {
                        if (dreamgradeResult.isInfinite) {
                          return "-";
                        } else {
                          return dreamgradeResult.toStringAsFixed(2);
                        }
                      })(), style: TextStyle(fontSize: 20)),
                    ],
                  )
                ],
              ),
            ),
          ));
    }),
  );
}
