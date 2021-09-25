import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely2/screens/main/grades/pdfView.dart';
import 'package:gradely2/screens/main/semesters.dart';
import 'package:gradely2/screens/main/lessons.dart';
import 'package:gradely2/shared/CLASSES.dart';
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

Grade selectedTest;
String errorMessage = "";
double averageOfGrades = 0;
List attachmentArray;
num _sumW = 0;
num _sum = 0;
_getAttachments() async {
  var _attachmentArray = jsonDecode((await database.getDocument(
              collectionId: collectionGrades, documentId: selectedTest.id))
          .toString())["attachments"] ??
      [];
  if (_attachmentArray == "") {
    attachmentArray = [];
  } else {
    attachmentArray = _attachmentArray;
  }
}

Future<String> getFileName(fileid) async {
  return jsonDecode((await storage.getFile(fileId: fileid)).toString())["name"];
}

var selectedDate = DateTime.now();
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();

class LessonsDetail extends StatefulWidget {
  @override
  _LessonsDetailState createState() => _LessonsDetailState();
}

class _LessonsDetailState extends State<LessonsDetail> {
  updateAverage() async {
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
    if (mounted) setState(() => isLoading = true);

    if (user.choosenSemester == null) {
      return ChooseSemester();
    }

    choosenSemester = user.choosenSemester;

    gradeList = (await listDocuments(
      orderField: "date",
      collection: collectionGrades,
      name: "gradeList_$selectedLesson",
      filters: ["parentId=$selectedLesson"],
    ))["documents"]
        .map((r) => Grade(
              r["\$id"],
              r["name"],
              double.parse(r["grade"].toString()),
              double.parse(r["weight"].toString()),
              r["date"] ?? "-",
            ))
        .toList();

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
    updateAverage();
    if (mounted) setState(() => isLoading = false);
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
          title: Text(selectedLessonName, style: title),
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
                                              color: frontColor(),
                                            ),
                                            onTap: () async {
                                              noNetworkDialog(context);
                                              selectedTest = gradeList[index];
                                              await _getAttachments();
                                              for (var file
                                                  in attachmentArray) {
                                                print(file);
                                                await storage.deleteFile(
                                                    fileId: file);
                                              }
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
                                              getTests();
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
                                                _getAttachments();
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
                                                      color: frontColor(),
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
                                                      color: frontColor(),
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

  Future testDetail(BuildContext context) {
    editTestInfoGrade.text = selectedTest.grade.toString();
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
                  noNetworkDialog(context);
                  try {
                    await database.updateDocument(
                        collectionId: collectionGrades,
                        documentId: selectedTest.id,
                        data: {
                          "name": editTestInfoName.text,
                          "grade": double.parse(
                            editTestInfoGrade.text.replaceAll(",", "."),
                          ),
                          "weight": double.parse(
                              editTestInfoWeight.text.replaceAll(",", ".")),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                  lastDate: DateTime(2035),
                  builder: (BuildContext context, Widget child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: Colors.black, onSurface: wbColor),
                        dialogBackgroundColor: bwColor,
                        textButtonTheme: TextButtonThemeData(
                            style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(primaryColor),
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
                  decoration: inputDec(label: "date".tr())),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: editTestInfoGrade,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            decoration: inputDec(label: "grade".tr()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: editTestInfoWeight,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            decoration: inputDec(label: "weight".tr()),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        gradelyIconButton(
            onPressed: () => gradeAttachment(context),
            icon: Icon(Icons.attach_file))
      ],
    );
  }

  Future addTest(BuildContext context) {
    uploadGrade() async {
      bool succeded = false;
      isLoadingController.add(true);
      noNetworkDialog(context);
      try {
        Future result = database.createDocument(
          collectionId: collectionGrades,
          data: {
            "parentId": selectedLesson,
            "name": addTestNameController.text,
            "grade":
                double.parse(addTestGradeController.text.replaceAll(",", ".")),
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
        await result.then((r) {
          r = jsonDecode(r.toString());
          selectedTest = Grade(
              r["\$id"],
              r["name"],
              double.parse(r["grade"].toString()),
              double.parse(r["weight"].toString()),
              r["date"]);
        }).catchError((error) {
          print(error);
        });
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

    addTestNameController.text = "";
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
          child: Text(
            "add_exam".tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                  lastDate: DateTime(2035),
                  builder: (BuildContext context, Widget child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: Colors.black, onSurface: wbColor),
                        dialogBackgroundColor: bwColor,
                        textButtonTheme: TextButtonThemeData(
                            style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(primaryColor),
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
                  decoration: inputDec(label: "date".tr())),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              controller: addTestGradeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.left,
              decoration: inputDec(label: "grade".tr())),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              controller: addTestWeightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.left,
              decoration: inputDec(label: "weight".tr())),
        ),
        SizedBox(
          height: 10,
        ),
        gradelyIconButton(
            onPressed: () async {
              if (await uploadGrade()) {
                print("testid" + selectedTest.id);
                await _getAttachments();
                gradeAttachment(context);
              }
            },
            icon: Icon(Icons.attach_file))
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
                            color: frontColor(),
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

Widget gradeAttachment(context) {
  if (!user.gradelyPlus) {
    return gradelyPlusDialog(context);
  } else {
    return gradelyModalSheet(
      context: context,
      children: [
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Column(children: [
            gradelyModalSheetHeader(context,
                customHeader: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 30,
                    ),
                    Text(
                      selectedTest.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    Text(" Beta")
                  ],
                )),
            Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: attachmentArray.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        decoration: listContainerDecoration(
                            index: index, list: attachmentArray),
                        child: ListTile(
                            trailing: IconButton(
                                icon: Icon(FontAwesome5Solid.trash_alt),
                                onPressed: () async {
                                  await storage.deleteFile(
                                      fileId: attachmentArray[index]);
                                  setState(() {
                                    attachmentArray
                                        .remove(attachmentArray[index]);
                                  });
                                  database.updateDocument(
                                      collectionId: collectionGrades,
                                      documentId: selectedTest.id,
                                      data: {"attachments": attachmentArray});
                                }),
                            onTap: () async {
                              String fileName =
                                  await getFileName(attachmentArray[index]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PdfViewPage(attachmentArray[index], fileName)),
                              );
                            },
                            leading: FutureBuilder<String>(
                                future: getFileName(attachmentArray[
                                    index]), // a Future<String> or null
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Text('Loading...');
                                    default:
                                      if (snapshot.hasError)
                                        return Text('File not found');
                                      else
                                        return Text(snapshot.data);
                                  }
                                })));
                  }),
            ),
            SizedBox(
              height: 20,
            ),
            gradelyButton(
                onPressed: () async {
                  if (attachmentArray.length >= 5) {
                    errorSuccessDialog(
                        context: context,
                        error: true,
                        text: "You can't upload more then 5 Files.");
                  } else {
                    FilePickerResult fileresult =
                        await FilePicker.platform.pickFiles();
                    if (fileresult != null) {
                      PlatformFile file = fileresult.files.first;
                      Future result = storage.createFile(
                          file: await MultipartFile.fromPath(
                        "file",
                        file.path,
                        filename: file.name,
                      ));

                      result.then((response) async {
                        setState(() {
                          attachmentArray
                              .add(jsonDecode(response.toString())["\$id"]);
                        });
                        await database.updateDocument(
                            collectionId: collectionGrades,
                            documentId: selectedTest.id,
                            data: {"attachments": attachmentArray});
                      }).catchError((error) {
                        print(error.response);
                      });
                    } else {
                      // User canceled the picker
                    }
                  }
                },
                text: "attach_pdf".tr()),
          ]);
        })
      ],
    );
  }
}
