import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely2/screens/main/semesters.dart';
import 'package:gradely2/screens/main/lessons.dart';
import 'package:gradely2/shared/CLASSES.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:gradely2/shared/defaultWidgets.dart';
import 'package:gradely2/shared/loading.dart';
import 'package:gradely2/screens/main/statistics.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';

Grade selectedTest;
String errorMessage = "";
double averageOfGrades = 0;

num _sumW = 0;
num _sum = 0;

var selectedDate = DateTime.now();
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();

class LessonsDetail extends StatefulWidget {
  @override
  _LessonsDetailState createState() => _LessonsDetailState();
}

class _LessonsDetailState extends State<LessonsDetail> {
  updateAverage() {
    database.updateDocument(
        documentId: selectedLesson,
        collectionId: collectionLessons,
        data: {
          "average": (() {
            if (averageOfGrades.isNaN) {
              return -99;
            } else {
              return averageOfGrades;
            }
          }()),
        });
  }

  getTests() async {
    setState(() => isLoading = true);
    gradeList = [];
    var response;

    if (user.choosenSemester == null) {
      return ChooseSemester();
    }

    choosenSemester = user.choosenSemester;

    response = await listDocuments(
      orderField: "date",
      collection: collectionGrades,
      name: "gradeList_$selectedLesson",
      filters: ["parentId=$selectedLesson"],
    );

    response = jsonDecode(response.toString())["documents"];

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
          gradeList.add(
            Grade(
              response[index]["\$id"],
              response[index]["name"],
              double.parse(response[index]["grade"].toString()),
              double.parse(response[index]["weight"].toString()),
              response[index]["date"] ?? "-",
            ),
          );
        });
      }
      gradeList.sort((a, b) => b.date.compareTo(a.date));

      _sumW = 0;
      _sum = 0;

      await Future.forEach(gradeList, (e) async {
        _sumW += e.weight;
        _sum += e.grade * e.weight;
      });

      setState(() {
        averageOfGrades = _sum / _sumW;
      });
    }
    updateAverage();
    setState(() => isLoading = false);
  }

  void initState() {
    super.initState();
    getTests();
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    darkModeColorChanger(context);

    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: primaryColor,
          ),
          backgroundColor: defaultBGColor,
          title: Text(selectedLessonName,
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.w800)),
          elevation: 0),
      body: Column(
        children: [
          isLoading
              ? GradelyLoadingIndicator()
              : Expanded(
                  child: gradeList.length == 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "empty_lesson_p1".tr() + " 🔎\n",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("empty_lesson_p2".tr() + " "),
                                    Icon(
                                      FontAwesome5Solid.plus,
                                      size: 15,
                                    ),
                                    Text(" " + "empty_lesson_p3".tr())
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: gradeList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    decoration: listContainerDecoration(
                                        index: index, list: gradeList),
                                    child: Slidable(
                                      actionPane: SlidableDrawerActionPane(),
                                      actionExtentRatio: 0.25,
                                      secondaryActions: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: IconSlideAction(
                                            color: primaryColor,
                                            iconWidget: Icon(
                                              FontAwesome5.trash_alt,
                                              color: Colors.white,
                                            ),
                                            onTap: () {
                                              noNetworkDialog(context);
                                              database.deleteDocument(
                                                  collectionId:
                                                      collectionGrades,
                                                  documentId:
                                                      gradeList[index].id);

                                              setState(() {
                                                gradeList.removeWhere((item) =>
                                                    item.id ==
                                                    gradeList[index].id);
                                              });
                                              updateAverage();
                                            },
                                          ),
                                        ),
                                      ],
                                      child: Column(
                                        children: [
                                          ListTile(
                                              title: Text(
                                                gradeList[index].name,
                                              ),
                                              subtitle: gradeList.isEmpty
                                                  ? Text("")
                                                  : Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .calculate_outlined,
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
                                                        Text((() {
                                                          if (gradeList[index]
                                                                  .date ==
                                                              "") {
                                                            return "  -";
                                                          } else {
                                                            return " " +
                                                                formatDateForClient(gradeList[
                                                                            index]
                                                                        .date
                                                                        .toString())
                                                                    .toString();
                                                          }
                                                        }())),
                                                      ],
                                                    ),
                                              trailing: Text(gradeList[index]
                                                  .grade
                                                  .toStringAsFixed(2)),
                                              onTap: () async {
                                                selectedTest = gradeList[index];

                                                testDetail(context);
                                              }),
                                          listDivider()
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
                    user.gradeType == "pp"
                        ? Column(
                            children: [
                              Text(
                                getPluspoints(averageOfGrades).toString(),
                                style: TextStyle(fontSize: 17),
                              ),
                              Text(
                                (() {
                                  if (averageOfGrades.isNaN) {
                                    return "-";
                                  } else {
                                    return averageOfGrades.toStringAsFixed(2);
                                  }
                                })(),
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 10),
                              ),
                            ],
                          )
                        : Text((() {
                            if (averageOfGrades.isNaN) {
                              return "-";
                            } else {
                              return averageOfGrades.toStringAsFixed(2);
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
                                                      dreamGradeC(context);
                                                    })),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("dream_grade".tr())
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
                                                                "error_stats_contain_no_date"
                                                                    .tr());
                                                      } else if (formatError) {
                                                        gradelyDialog(
                                                            context: context,
                                                            title: "error".tr(),
                                                            text:
                                                                "error_stats_date_badly_formatted"
                                                                    .tr());
                                                      } else {
                                                        statisticsScreen(
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
    editTestInfoGrade.text = selectedTest.grade.toString();
    editTestInfoName.text = selectedTest.name;
    editTestInfoWeight.text = selectedTest.weight.toString();

    editTestDateController.text =
        formatDateForClient(selectedTest.date.toString());

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
                      gradelyIconButton(
                          onPressed: () async {
                            isLoadingController.add(true);
                            noNetworkDialog(context);
                            try {
                              await database.updateDocument(
                                  collectionId: collectionGrades,
                                  documentId: selectedTest.id,
                                  data: {
                                    "name": editTestInfoName.text,
                                    "grade": double.parse(
                                      editTestInfoGrade.text
                                          .replaceAll(",", "."),
                                    ),
                                    "weight": double.parse(editTestInfoWeight
                                        .text
                                        .replaceAll(",", ".")),
                                    "date": (() {
                                      try {
                                        return formatDateForDB(
                                            editTestDateController.text);
                                      } catch (_) {
                                        return "-";
                                      }
                                    }())
                                  });
                              await getTests();
                              Navigator.of(context).pop();
                              isLoadingController.add(false);
                            } catch (_) {
                              isLoadingController.add(false);
                              errorSuccessDialog(
                                  context: context,
                                  error: true,
                                  text: "error_grade_badly_formatted".tr());
                            }
                          },
                          icon: Icon(Icons.edit)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Text(
                      selectedTest.name,
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
                      decoration: inputDec(label: "exam_name".tr()),
                      inputFormatters: [emojiRegex()],
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
                            editTestDateController.text =
                                formatDateForClient(picked);
                          });
                      },
                      child: AbsorbPointer(
                        child: TextField(
                            controller: editTestDateController,
                            textAlign: TextAlign.left,
                            decoration: inputDec(label: "date".tr())),
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
                      decoration: inputDec(label: "grade".tr()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: editTestInfoWeight,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.left,
                      decoration: inputDec(label: "weight".tr()),
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
                          gradelyIconButton(
                              onPressed: () async {
                                isLoadingController.add(true);
                                noNetworkDialog(context);
                                try {
                                  await database.createDocument(
                                    collectionId: collectionGrades,
                                    data: {
                                      "parentId": selectedLesson,
                                      "name": addTestNameController.text,
                                      "grade": double.parse(
                                          addTestGradeController.text
                                              .replaceAll(",", ".")),
                                      "weight": double.parse(
                                          addTestWeightController.text
                                              .replaceAll(",", ".")),
                                      "date": (() {
                                        try {
                                          return formatDateForDB(
                                              addTestDateController.text);
                                        } catch (_) {
                                          return null;
                                        }
                                      }())
                                    },
                                  );

                                  await getTests();
                                  addLessonController.text = "";

                                  Navigator.of(context).pop();
                                  isLoadingController.add(false);
                                } catch (_) {
                                  isLoadingController.add(false);
                                  errorSuccessDialog(
                                      context: context,
                                      error: true,
                                      text: "error_grade_badly_formatted".tr());
                                }
                              },
                              icon: Icon(Icons.add)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
                          "add_exam".tr(),
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
                          decoration: inputDec(label: "exam_name".tr()),
                          inputFormatters: [emojiRegex()],
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
                                DateTime.parse(picked.toString());
                                addTestDateController.text =
                                    formatDateForClient(picked);
                              });
                          },
                          child: AbsorbPointer(
                            child: TextField(
                                controller: addTestDateController,
                                textAlign: TextAlign.left,
                                decoration: inputDec(label: "date".tr())),
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
                            decoration: inputDec(label: "grade".tr())),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                            controller: addTestWeightController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.left,
                            decoration: inputDec(label: "weight".tr())),
                      ),
                      Text(errorMessage)
                    ],
                  )),
            ));
      }),
    );
  }
}

Future dreamGradeC(BuildContext context) {
  dreamGradeGrade.text = "";
  dreamGradeWeight.text = "1";
  num dreamgradeResult = 0;
  double dreamgrade = 0;
  double dreamgradeWeight = 1;

  return showCupertinoModalBottomSheet(
    expand: true,
    context: context,
    builder: (context) =>
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
                      Text("dream_grade_calulator".tr(),
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
                      decoration: inputDec(label: "dream_grade".tr()),
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
                      decoration: inputDec(label: "dream _grade_weight".tr()),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Text("dream_grade_result_text".tr() + "  "),
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
