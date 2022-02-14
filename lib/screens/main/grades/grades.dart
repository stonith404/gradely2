import "package:flutter/cupertino.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:gradely2/components/controllers/grade_controller.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/utils/grades.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/components/widgets/dialogs.dart";
import "package:gradely2/components/widgets/loading.dart";
import "package:gradely2/main.dart";
import "package:gradely2/screens/main/grades/create_grade.dart";
import "package:gradely2/screens/main/grades/dream_grade_calculator.dart";
import "package:gradely2/screens/main/grades/update_grade.dart";
import "package:gradely2/screens/main/subjects/subjects.dart";
import "package:gradely2/components/variables.dart";
import "package:gradely2/screens/main/grades/statistics.dart";
import "package:flutter/material.dart";
import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:native_context_menu/native_context_menu.dart";

String errorMessage = "";
double averageOfGrades = 0;
num _sumW = 0;
num _sum = 0;

class GradesScreen extends StatefulWidget {
  const GradesScreen({Key? key}) : super(key: key);

  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  GradeController gradeController =
      GradeController(navigatorKey.currentContext);
  List<Grade> _gradeList = [];

  updateAverage() async {
    _sumW = 0;
    _sum = 0;
    await Future.forEach(_gradeList, (dynamic e) async {
      if (e.grade != -99) {
        _sumW += e.weight;
        _sum += e.grade * e.weight;
      }
    });

    setState(() {
      averageOfGrades = _sum / _sumW;
    });
    api.updateDocument(context,
        documentId: selectedSubject.id,
        collectionId: collectionSubjects,
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

  Future<void> getTests({bool initalFetch = false}) async {
    if (initalFetch) setState(() => isLoading = true);
    _gradeList = await (gradeController.list(selectedSubject.id));
    updateAverage();
    setState(() => _gradeList);
    setState(() => isLoading = false);
  }

  void deleteGrade(index) {
    gradeController.delete(_gradeList[index].id);
    setState(() =>
        _gradeList.removeWhere((item) => item.id == _gradeList[index].id));
    updateAverage();
  }

  @override
  void initState() {
    super.initState();
    getTests(initalFetch: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSubject.name, style: title),
      ),
      body: Column(
        children: [
          isLoading
              ? GradelyLoadingIndicator()
              : Expanded(
                  child: _gradeList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "empty_subject_p1".tr() + " 🔎\n",
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
                                          text: "empty_subject_p2".tr() + " ",
                                        ),
                                        WidgetSpan(
                                          child: Icon(
                                            isCupertino
                                                ? CupertinoIcons.plus
                                                : Icons.add,
                                            size: 15,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " " + "empty_subject_p3".tr(),
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
                                itemCount: _gradeList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    decoration: listContainerDecoration(context,
                                        index: index, list: _gradeList),
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
                                                isCupertino
                                                    ? CupertinoIcons.delete
                                                    : Icons.delete_outline,
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
                                                {item.onSelected!()},
                                            menuItems: [
                                              MenuItem(
                                                onSelected: () =>
                                                    deleteGrade(index),
                                                title: "delete".tr(),
                                              ),
                                            ],
                                            child: ListTile(
                                                title: Text(
                                                  _gradeList[index].name,
                                                ),
                                                subtitle: _gradeList.isEmpty
                                                    ? Text("")
                                                    : Row(
                                                        children: [
                                                          Icon(
                                                            isCupertino
                                                                ? CupertinoIcons
                                                                    .bag
                                                                : Icons
                                                                    .calculate_outlined,
                                                            size: 20,
                                                          ),
                                                          Text(" " +
                                                              _gradeList[index]
                                                                  .weight
                                                                  .toString() +
                                                              "   "),
                                                          Icon(
                                                            isCupertino
                                                                ? CupertinoIcons
                                                                    .calendar
                                                                : Icons
                                                                    .date_range,
                                                            size: 20,
                                                          ),
                                                          Text((() {
                                                            if (_gradeList[
                                                                        index]
                                                                    .date ==
                                                                "") {
                                                              return "  -";
                                                            } else {
                                                              return " " +
                                                                  formatDateForClient(_gradeList[
                                                                              index]
                                                                          .date
                                                                          .toString())
                                                                      .toString();
                                                            }
                                                          }())),
                                                        ],
                                                      ),
                                                trailing: Text(_gradeList[index]
                                                            .grade ==
                                                        -99
                                                    ? "-"
                                                    : _gradeList[index]
                                                        .grade
                                                        .toStringAsFixed(2)),
                                                onTap: () => updateGrade(
                                                        context,
                                                        grade:
                                                            _gradeList[index])
                                                    .then((_) => getTests())),
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
              boxShadow: const [],
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
                        onPressed: () => createGrade(
                              context,
                              subjectId: selectedSubject.id,
                              gradeOffset: _gradeList.length,
                            ).then((_) => getTests())),
                    IconButton(
                        color: Theme.of(context).primaryColorDark,
                        icon: Icon(
                            isCupertino
                                ? CupertinoIcons.plus_slash_minus
                                : Icons.calculate,
                            size: 17),
                        onPressed: () {
                          showModalBottomSheet(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              context: context,
                              builder: (context) => SizedBox(
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
                                                      isCupertino
                                                          ? CupertinoIcons
                                                              .plus_slash_minus
                                                          : Icons
                                                              .calculate_outlined,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      dreamGradeCalculator(
                                                          context,
                                                          sumWeight: _sumW as double,
                                                          sumGrade: _sum as double);
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
                                                      isCupertino
                                                          ? CupertinoIcons
                                                              .chart_bar
                                                          : Icons
                                                              .bar_chart_outlined,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();

                                                      if (_gradeList
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
                                                            context,
                                                            gradeList:
                                                                _gradeList);
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
}
