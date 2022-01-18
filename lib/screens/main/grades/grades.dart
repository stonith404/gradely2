import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely2/screens/main/semesters.dart';
import 'package:gradely2/screens/main/subjects.dart';
import 'package:gradely2/shared/MODELS.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:gradely2/shared/loading.dart';
import 'package:gradely2/screens/main/grades/statistics.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:native_context_menu/native_context_menu.dart';

String errorMessage = "";
double averageOfGrades = 0;
num _sumW = 0;
num _sum = 0;

Future<String> getFileName(fileid) async {
  return jsonDecode((await storage.getFile(fileId: fileid)).toString())["name"];
}

var selectedDate = DateTime.now();
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();

class GradesScreen extends StatefulWidget {
  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  updateAverage() async {
    _sumW = 0;
    _sum = 0;
    await Future.forEach(gradeList, (e) async {
      if (e.grade != -99) {
        _sumW += e.weight;
        _sum += e.grade * e.weight;
      }
    });

    setState(() {
      averageOfGrades = _sum / _sumW;
    });
    api.updateDocument(context,
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
    if (mounted) setState(() => isLoading = true);

    if (user.choosenSemester == null) {
      return SemesterScreen();
    }

    choosenSemester = user.choosenSemester;

    gradeList = (await api.listDocuments(
      orderField: "date",
      collection: collectionGrades,
      name: "gradeList_$selectedLesson",
      queries: [Query.equal("parentId", selectedLesson)],
    ))
        .map((r) => Grade(
              r["\$id"],
              r["name"],
              double.parse(r["grade"].toString()),
              double.parse(r["weight"].toString()),
              r["date"] ?? "-",
            ))
        .toList();

    gradeList.sort((a, b) => b.date.compareTo(a.date));

    updateAverage();
    if (mounted) setState(() => isLoading = false);
  }

  deleteGrade(index) {
    api.deleteDocument(context,
        collectionId: collectionGrades, documentId: gradeList[index].id);

    setState(() {
      gradeList.removeWhere((item) => item.id == gradeList[index].id);
    });
    updateAverage();
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
        title: Text(selectedLessonName, style: title),
      ),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                      children: [
                                        TextSpan(
                                          text: "empty_lesson_p2".tr() + " ",
                                        ),
                                        WidgetSpan(
                                          child: Icon(
                                            FontAwesome5Solid.plus,
                                            size: 15,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " " + "empty_lesson_p3".tr(),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                    decoration: listContainerDecoration(context,
                                        index: index, list: gradeList),
                                    child: Slidable(
                                      actionPane: SlidableDrawerActionPane(),
                                      actionExtentRatio: 0.25,
                                      secondaryActions: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: IconSlideAction(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              iconWidget: Icon(
                                                FontAwesome5.trash_alt,
                                                color: Theme.of(context)
                                                    .primaryColorLight,
                                              ),
                                              onTap: () => deleteGrade(index)),
                                        ),
                                      ],
                                      child: Column(
                                        children: [
                                          ContextMenuRegion(
                                            onItemSelected: (item) =>
                                                {item.onSelected()},
                                            menuItems: [
                                              MenuItem(
                                                onSelected: () =>
                                                    deleteGrade(index),
                                                title: 'delete'.tr(),
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
                                                            .grade ==
                                                        -99
                                                    ? "-"
                                                    : gradeList[index]
                                                        .grade
                                                        .toStringAsFixed(2)),
                                                onTap: () async {
                                                  testDetail(context,
                                                      gradeList[index]);
                                                }),
                                          ),
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
              color: Theme.of(context).backgroundColor,
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
                        color: Theme.of(context).primaryColorDark,
                        icon: Icon(Icons.add),
                        onPressed: () {
                          addTest(context);
                        }),
                    IconButton(
                        color: Theme.of(context).primaryColorDark,
                        icon: Icon(FontAwesome5Solid.calculator, size: 17),
                        onPressed: () {
                          showModalBottomSheet(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
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
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColorDark,
                                                child: IconButton(
                                                    icon: Icon(
                                                      FontAwesome5Solid
                                                          .calculator,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
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
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColorDark,
                                                child: IconButton(
                                                    icon: Icon(
                                                      FontAwesome5.chart_bar,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();

                                                      if (gradeList
                                                          .where((element) =>
                                                              element.date ==
                                                                  "" ||
                                                              element.date ==
                                                                  "-")
                                                          .toList()
                                                          .isNotEmpty) {
                                                        gradelyDialog(
                                                            context: context,
                                                            title: "error".tr(),
                                                            text:
                                                                "error_stats_contain_no_date"
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

  Future testDetail(BuildContext context, Grade selectedTest) {
    editTestInfoGrade.text =
        selectedTest.grade == -99 ? "" : selectedTest.grade.toString();
    editTestInfoName.text = selectedTest.name;
    editTestInfoWeight.text = selectedTest.weight.toString();
    editTestDateController.text =
        formatDateForClient(selectedTest.date.toString());

    return gradelyModalSheet(
      context: context,
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
                  try {
                    await api.updateDocument(context,
                        collectionId: collectionGrades,
                        documentId: selectedTest.id,
                        data: {
                          "name": editTestInfoName.text,
                          "grade": (() {
                            try {
                              return double.parse(
                                  editTestInfoGrade.text.replaceAll(",", "."));
                            } catch (_) {
                              return -99.0;
                            }
                          }()),
                          "weight": double.parse(
                              editTestInfoWeight.text.replaceAll(",", ".")),
                          "date": (() {
                            try {
                              return formatDateForDB(
                                  editTestDateController.text);
                            } catch (_) {
                              return "";
                            }
                          }())
                        });
                    Navigator.of(context).pop();
                    await getTests();
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
            style: bigTitle,
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
            decoration: inputDec(context, label: "exam_name".tr()),
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
                  lastDate: DateTime(2035),
                  builder: (BuildContext context, Widget child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: Colors.black,
                            onSurface: Theme.of(context).primaryColorDark),
                        dialogBackgroundColor:
                            Theme.of(context).backgroundColor,
                        textButtonTheme: TextButtonThemeData(
                            style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColorDark),
                        )),
                      ),
                      child: child,
                    );
                  });
              if (picked != null && picked != selectedDate)
                setState(() {
                  editTestDateController.text = formatDateForClient(picked);
                });
            },
            child: AbsorbPointer(
              child: TextField(
                  controller: editTestDateController,
                  textAlign: TextAlign.left,
                  decoration: inputDec(context, label: "date".tr())),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: editTestInfoGrade,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            decoration: inputDec(context, label: "grade".tr()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: editTestInfoWeight,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            decoration: inputDec(context, label: "weight".tr()),
          ),
        ),
      ],
    );
  }

  Future addTest(BuildContext context) {
    uploadGrade() async {
      bool succeded = false;
      isLoadingController.add(true);

      try {
        await api.createDocument(
          context,
          collectionId: collectionGrades,
          data: {
            "parentId": selectedLesson,
            "name": addTestNameController.text,
            "grade": (() {
              try {
                return double.parse(
                    addTestGradeController.text.replaceAll(",", "."));
              } catch (_) {
                return -99.0;
              }
            }()),
            "weight":
                double.parse(addTestWeightController.text.replaceAll(",", ".")),
            "date": (() {
              try {
                return formatDateForDB(addTestDateController.text);
              } catch (_) {
                return null;
              }
            }())
          },
        );
        await getTests();
        addLessonController.text = "";
        succeded = true;
        Navigator.of(context).pop();
        isLoadingController.add(false);
      } catch (_) {
        succeded = false;
        isLoadingController.add(false);
        errorSuccessDialog(
            context: context,
            error: true,
            text: "error_grade_badly_formatted".tr());
      }
      return succeded;
    }

    addTestNameController.text = "exam".tr() + " ${gradeList.length + 1}";
    addTestGradeController.text = "";
    addTestDateController.text = "";
    addTestWeightController.text = "1";

    return gradelyModalSheet(
      context: context,
      children: [
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            gradelyIconButton(
                onPressed: () => uploadGrade(), icon: Icon(Icons.add)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: FittedBox(
            child: Text(
              "add_exam".tr(),
              style: bigTitle,
            ),
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
            decoration: inputDec(context, label: "exam_name".tr()),
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
                  lastDate: DateTime(2035),
                  builder: (BuildContext context, Widget child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: Colors.black,
                            onSurface: Theme.of(context).primaryColorDark),
                        dialogBackgroundColor:
                            Theme.of(context).backgroundColor,
                        textButtonTheme: TextButtonThemeData(
                            style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColorDark),
                        )),
                      ),
                      child: child,
                    );
                  });

              if (picked != null && picked != selectedDate)
                setState(() {
                  DateTime.parse(picked.toString());
                  addTestDateController.text = formatDateForClient(picked);
                });
            },
            child: AbsorbPointer(
              child: TextField(
                  controller: addTestDateController,
                  textAlign: TextAlign.left,
                  decoration: inputDec(context, label: "date".tr())),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              controller: addTestGradeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.left,
              decoration: inputDec(context, label: "grade".tr())),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              controller: addTestWeightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.left,
              decoration: inputDec(context, label: "weight".tr())),
        ),
        SizedBox(
          height: 10,
        ),
      ],
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
            color: Theme.of(context).scaffoldBackgroundColor,
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
                      Flexible(
                          child: FittedBox(
                              child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("dream_grade_calulator".tr(), style: title),
                      ))),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Theme.of(context).primaryColorDark,
                        child: IconButton(
                            color: Theme.of(context).primaryColorLight,
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
                      decoration: inputDec(context, label: "dream_grade".tr()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
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
                      decoration:
                          inputDec(context, label: "dream _grade_weight".tr()),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                      children: [
                        TextSpan(text: "dream_grade_result_text".tr() + "  "),
                        TextSpan(
                            text: (() {
                              if (dreamgradeResult.isInfinite) {
                                return "-";
                              } else {
                                return dreamgradeResult.toStringAsFixed(2);
                              }
                            })(),
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ));
    }),
  );
}
