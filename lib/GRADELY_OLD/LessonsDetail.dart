import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/GRADELY_OLD/shared/CLASSES.dart';
import 'package:gradely/GRADELY_OLD/shared/VARIABLES..dart';
import 'package:gradely/GRADELY_OLD/statistics.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:flutter/material.dart';
import 'package:gradely/GRADELY_OLD/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/GRADELY_OLD/userAuth/login.dart';
import 'package:gradely/GRADELY_OLD/chooseSemester.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:gradely/GRADELY_OLD/shared/defaultWidgets.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';

bool buttonDisabled = false;
String selectedTest = "";
String errorMessage = "";
double averageOfTests = 0;
List<String> testListID = [];
List<String> dateList = [];
List<num> averageList = [];
List<num> averageListWeight = [];
num _sumWeight = 0;
num _sumGrade = 0;
var defaultBGColor;
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
    if (kIsWeb) {
      cache = false;
    }
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

    print(cache);

    List<DocumentSnapshot> documents = result.docs;
    gradeList = [];

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
        testList.add(data["name"]);

        gradeList.add(Grade(
            data["name"],
            data.id,
            double.parse(data["grade"].toString()),
            double.parse(data["weight"].toString()),
            data["date"]));
      });

//this calculates the average of the tests
      _sumWeight = 0;
      _sumGrade = 0;

      for (var e in gradeList) {
        _sumWeight += e.weight;
        _sumGrade += e.grade * e.weight;
      }

      setState(() {
        averageOfTests = _sumGrade / _sumWeight;
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

  void initState() {
    super.initState();
    getTests(true);
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
    });
    getPluspoints(averageOfTests);
    darkModeColorChanger(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: buttonDisabled
                  ? null
                  : () async {
                      if (!kIsWeb) {
                        await checkForNetwork();

                        if (internetConnected) {
                          setState(() {
                            buttonDisabled = true;
                            Timer(Duration(seconds: 20), () {
                              setState(() => buttonDisabled = false);
                            });
                          });

                          getTests();
                        } else {
                          gradelyDialog(
                              context: context,
                              title: "error".tr(),
                              text: "notConnectedToInternet".tr());
                        }
                      } else {
                        setState(() {
                          buttonDisabled = true;
                          Timer(Duration(seconds: 20), () {
                            setState(() => buttonDisabled = false);
                          });
                        });

                        getTests();
                      }
                    },
              icon: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  FontAwesome5Solid.sync,
                  size: 17,
                  color: primaryColor,
                ),
              ))
        ],
        backgroundColor: defaultBGColor,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              color: primaryColor,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeWrapper()),
                (Route<dynamic> route) => false,
              );
              try {
                timer.cancel();
              } catch (e) {}
            }),
        title: Text(
          selectedLessonName,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: primaryColor,
          ),
        ),
        shape: defaultRoundedCorners(),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: testListID.length == 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
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
                    ),
                  )
                : ListView.builder(
                    itemCount: gradeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Container(
                          decoration: (() {
                            if (index == 0) {
                              return BoxDecoration(
                                  color: bwColor,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ));
                            } else if (index == gradeList.length - 1) {
                              return BoxDecoration(
                                  color: bwColor,
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(15),
                                  ));
                            } else {
                              return BoxDecoration(
                                color: bwColor,
                              );
                            }
                          }()),
                          child: Column(
                            children: [
                              Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                secondaryActions: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: IconSlideAction(
                                      color: primaryColor,
                                      iconWidget: Icon(
                                        FontAwesome5.trash_alt,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        FirebaseFirestore.instance
                                            .collection(
                                                'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/$selectedLesson/grades')
                                            .doc(gradeList[index].id)
                                            .delete();

                                        getTests(true);
                                      },
                                    ),
                                  ),
                                ],
                                child: ListTile(
                                    title: Text(
                                      gradeList[index].name,
                                    ),
                                    subtitle: gradeList.isEmpty
                                        ? Text("")
                                        : Row(
                                            children: [
                                              Icon(
                                                Icons.calculate_outlined,
                                                size: 20,
                                              ),
                                              Text(" " +
                                                  gradeList[index]
                                                      .weight
                                                      .toString() +
                                                  "   "),
                                              Icon(
                                                Icons.date_range,
                                                size: 20,
                                              ),
                                              Text(" " +
                                                  gradeList[index]
                                                      .date
                                                      .toString()),
                                            ],
                                          ),
                                    trailing: Text(() {
                                      if ((averageList[index] /
                                              averageListWeight[index])
                                          .isNaN) {
                                        return "-";
                                      } else {
                                        return (gradeList[index].grade)
                                            .toStringAsFixed(2);
                                      }
                                    }()),
                                    onTap: () async {
                                      getTests(true);

                                      selectedTest = gradeList[index].id;

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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0),
                                child: Divider(
                                  thickness: 0.7,
                                  height: 1,
                                ),
                              )
                            ],
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
                        }),
                    IconButton(
                        icon: Icon(FontAwesome5Solid.calculator, size: 17),
                        onPressed: () {
                          showModalBottomSheet(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              context: context,
                              builder: (context) => Container(
                                    height: 150,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Spacer(flex: 10),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                                radius: 22,
                                                backgroundColor: primaryColor,
                                                child: IconButton(
                                                    icon: Icon(
                                                      FontAwesome5Solid
                                                          .calculator,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      DreamGradeC(context);
                                                    })),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("dream grade".tr())
                                          ],
                                        ),
                                        Spacer(flex: 5),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                                radius: 22,
                                                backgroundColor: primaryColor,
                                                child: IconButton(
                                                    icon: Icon(
                                                      FontAwesome5.chart_bar,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      bool formatError = false;
                                                      for (var e in gradeList) {
                                                        try {
                                                          if (e.date[2]
                                                              .contains(".")) {
                                                            formatError = true;
                                                          }
                                                        } catch (e) {
                                                          formatError = true;
                                                        }
                                                      }
                                                      if (gradeList
                                                          .contains("-")) {
                                                        gradelyDialog(
                                                            context: context,
                                                            title: "error".tr(),
                                                            text:
                                                                "statsContainsNoDate"
                                                                    .tr());
                                                      } else if (formatError) {
                                                        gradelyDialog(
                                                            context: context,
                                                            title: "error".tr(),
                                                            text:
                                                                "statsDateBadlyFormatted"
                                                                    .tr());
                                                      } else {
                                                        StatisticsScreen(
                                                            context);
                                                      }
                                                    })),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("statistics".tr())
                                          ],
                                        ),
                                        Spacer(flex: 10),
                                      ],
                                    ),
                                  ));
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                        backgroundColor: primaryColor,
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
                                    surface: primaryColor,
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
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                            backgroundColor: primaryColor,
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
                                        surface: primaryColor,
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
                                    "${_formatted.year}.${_formatted.month}." +
                                        (_formatted.day.toString().length > 1
                                            ? _formatted.day.toString()
                                            : "0${_formatted.day}");
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
                ((dreamgrade * (_sumWeight + dreamgradeWeight) - _sumGrade) /
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
                        backgroundColor: primaryColor,
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
