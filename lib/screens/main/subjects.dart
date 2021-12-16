import 'package:flutter/foundation.dart';
import 'package:gradely2/screens/auth/introScreen.dart' as introScreen;
import 'package:universal_io/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely2/screens/settings/settings.dart';
import 'package:gradely2/shared/CLASSES.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:gradely2/shared/loading.dart';
import 'semesters.dart';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:emoji_chooser/emoji_chooser.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:native_context_menu/native_context_menu.dart';

var action;
String selectedLesson = "";
String selectedLessonName;
String _selectedEmoji = "";
double _averageOfSemester = 0 / -0;
double _averageOfSemesterPP = 0 / -0;
Semester selectedSemester;

class SubjectScreen extends StatefulWidget {
  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  getLessons(loading) async {
    if (loading) setState(() => isLoading = true);
//get choosen semester name
    var semesterResponse = await api.listDocuments(
        collection: collectionSemester,
        name: "semesterName",
        filters: ["\$id=${user.choosenSemester}"]);
    setState(() {
      selectedSemester = semesterResponse["documents"]
          .map((r) => Semester(r["\$id"], r["name"], r["round"]))
          .toList()[0];
    });

    lessonList = (await api.listDocuments(
            collection: collectionLessons,
            name: "lessonList_${user.choosenSemester}",
            filters: ["parentId=${user.choosenSemester}"]))["documents"]
        .map((r) => Lesson(r["\$id"], r["name"], r["emoji"],
            double.parse(r["average"].toString())))
        .toList();

    lessonList.sort((a, b) => b.average.compareTo(a.average));

    setState(() => isLoading = false);

    //get the semester average
    if (lessonList.length == 0) {
      _averageOfSemesterPP = -99;
      _averageOfSemester = -99;
    } else {
      double _sum = 0;
      double _ppSum = 0;
      double _count = 0;
      for (var e in lessonList) {
        if (e.average != -99) {
          _sum += e.average;
          _ppSum += getPluspoints(e.average);
          _count = _count + 1;

          setState(() {
            _averageOfSemesterPP = _ppSum;
            _averageOfSemester = _sum / _count;
          });
        }
      }
    }
  }

  deleteLesson(index) {
    gradelyDialog(
      context: context,
      title: "warning".tr(),
      text:
          '${"delete_confirmation_p1".tr()} "${lessonList[index].name}" ${"delete_confirmation_p2".tr()}',
      actions: <Widget>[
        CupertinoButton(
          child: Text(
            "no".tr(),
            style: TextStyle(color: wbColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoButton(
          child: Text(
            "delete".tr(),
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            api.deleteDocument(context,
                collectionId: collectionLessons,
                documentId: lessonList[index].id);
            setState(() {
              lessonList.removeWhere((item) => item.id == lessonList[index].id);
            });
            getLessons(false);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getLessons(true);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      completeOfflineTasks(context);
      askForInAppRating();
      //notify the user that Gradely 2 Web isn't recommended.
      if (!(prefs.getBool("webNotRecommendedPopUp") ?? false) && kIsWeb) {
        gradelyDialog(
            context: context,
            title: "web_popup_title".tr(),
            text: "web_popup_description".tr(),
            actions: [
              TextButton(
                  onPressed: () {
                    prefs.setBool("webNotRecommendedPopUp", true);
                    launchURL("https://gradelyapp.com#download");
                  },
                  child: Text("download".tr())),
              TextButton(
                  onPressed: () {
                    prefs.setBool("webNotRecommendedPopUp", true);
                    Navigator.of(context).pop();
                  },
                  child: Text("Ok".tr()))
            ]);
      }
    });
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenwidth = MediaQuery.of(context).size.width;
    darkModeColorChanger(context);
    if (user.choosenSemester == "noSemesterChoosed") {
      return SemesterScreen();
    } else if (!user.emailVerification) {
      return introScreen.Intro6();
    } else if (isLoading) {
      return LoadingScreen();
    } else {
      return Scaffold(
          body: Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        backgroundColor: defaultBGColor,
                        elevation: 0,
                        title: SvgPicture.asset("assets/images/logo.svg",
                            color: primaryColor, height: 30),
                        leading: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: IconButton(
                              icon: Icon(Icons.segment, color: primaryColor),
                              onPressed: () async {
                                settingsScreen(context);
                              }),
                        ),
                        actions: [
                          IconButton(
                              icon:
                                  Icon(Icons.switch_left, color: primaryColor),
                              onPressed: () async {
                                Navigator.pushNamed(context, "semesters")
                                    .then((value) => getLessons(false));
                              }),
                        ],
                      ),
                    ];
                  },
                  body: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: ListView(padding: EdgeInsets.zero, children: [
                      Container(
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            )),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedSemester.name,
                                    style: TextStyle(
                                        fontFamily: "PlayfairDisplay",
                                        fontWeight: FontWeight.w900,
                                        fontSize: 28,
                                        color: frontColor()),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      child: Row(
                                        children: [
                                          Text("Ø",
                                              style: TextStyle(
                                                fontSize: 19,
                                                color: frontColor(),
                                              )),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                              _averageOfSemester.isNaN ||
                                                      _averageOfSemester == -99
                                                  ? "-"
                                                  : roundGrade(
                                                      _averageOfSemester,
                                                      selectedSemester.round),
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: frontColor(),
                                              )),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          user.gradeType == "av"
                                              ? Container()
                                              : Icon(
                                                  Icons
                                                      .add_circle_outline_outlined,
                                                  size: 19,
                                                  color: frontColor(),
                                                ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          user.gradeType == "av"
                                              ? Container()
                                              : Text(
                                                  _averageOfSemester.isNaN ||
                                                          _averageOfSemester ==
                                                              -99
                                                      ? "0"
                                                      : _averageOfSemesterPP
                                                          .toString(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: frontColor(),
                                                  ))
                                        ],
                                      )),
                                ],
                              ),
                              Spacer(flex: 1),
                              IconButton(
                                  icon: Icon(Icons.add),
                                  color: frontColor(),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      GradelyPageRoute(
                                          builder: (context) => addLesson()),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ),
                      Platform.isMacOS || Platform.isWindows
                          ? SizedBox(
                              height: 10,
                            )
                          : Container(),
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: lessonList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Slidable(
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
                                      color: frontColor(),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                updateLesson()),
                                      );
                                      selectedLessonName =
                                          lessonList[index].name;
                                      _selectedEmoji = lessonList[index].emoji;
                                      selectedLesson = lessonList[index].id;
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
                                        color: frontColor(),
                                      ),
                                      onTap: () => deleteLesson(index)),
                                ),
                              ],
                              child: Container(
                                decoration: listContainerDecoration(
                                    index: index, list: lessonList),
                                child: Column(
                                  children: [
                                    ContextMenuRegion(
                                      onItemSelected: (item) =>
                                          {item.onSelected()},
                                      menuItems: [
                                        MenuItem(
                                          onSelected: () => deleteLesson(index),
                                          title: 'delete'.tr(),
                                        ),
                                        MenuItem(
                                            onSelected: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          updateLesson()),
                                                ),
                                            title: 'rename'.tr()),
                                      ],
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Text(lessonList[index].emoji + "  ",
                                                style: TextStyle(
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 5.0,
                                                      color: darkmode
                                                          ? Colors.grey[900]
                                                          : Colors.grey[350],
                                                      offset: Offset(2.0, 2.0),
                                                    ),
                                                  ],
                                                )),
                                            Text(
                                              lessonList[index].name,
                                            ),
                                          ],
                                        ),
                                        trailing: Text(
                                          (() {
                                            if (lessonList[index].average ==
                                                -99) {
                                              return "-";
                                            } else if (user.gradeType == "pp") {
                                              return getPluspoints(
                                                      lessonList[index].average)
                                                  .toString();
                                            } else {
                                              return roundGrade(
                                                  lessonList[index].average,
                                                  selectedSemester.round);
                                            }
                                          })(),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(context, "grades")
                                              .then((value) {
                                            getLessons(false);
                                          });

                                          selectedLesson = lessonList[index].id;
                                          selectedLessonName =
                                              lessonList[index].name;
                                        },
                                      ),
                                    ),
                                    listDivider(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
              )));
    }
  }

  addLesson() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: primaryColor,
          ),
          backgroundColor: defaultBGColor,
          elevation: 0,
          title: Text("add_lesson".tr(), style: appBarTextTheme),
          shape: defaultRoundedCorners(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    _selectedEmoji = "";
                  });
                },
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext subcontext) {
                      return Container(
                        height: 290,
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            EmojiChooser(
                              columns: ((() {
                                if (screenwidth > 1700) {
                                  return 35;
                                } else if (screenwidth > 1100) {
                                  return 45;
                                } else if (screenwidth > 900) {
                                  return 38;
                                } else if (screenwidth > 800) {
                                  return 30;
                                } else if (screenwidth > 700) {
                                  return 28;
                                } else if (screenwidth > 600) {
                                  return 25;
                                } else if (screenwidth > 500) {
                                  return 15;
                                } else if (screenwidth > 400) {
                                  return 15;
                                } else if (screenwidth < 400) {
                                  return 10;
                                }
                              })()),
                              onSelected: (_emoji) {
                                setState(() {
                                  _selectedEmoji = _emoji.char;
                                });

                                Navigator.of(subcontext).pop(_emoji);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ((() {
                  if (_selectedEmoji == "") {
                    return Text(
                      "no_emoji_choosed".tr(),
                      style: TextStyle(color: primaryColor),
                    );
                  } else {
                    return Text(
                      _selectedEmoji.toString(),
                      style: TextStyle(fontSize: 70),
                    );
                  }
                })()),
              ),
              Spacer(flex: 2),
              TextField(
                  inputFormatters: [emojiRegex()],
                  controller: addLessonController,
                  textAlign: TextAlign.left,
                  decoration: inputDec(label: "lesson_name".tr())),
              SizedBox(
                height: 40,
              ),
              gradelyButton(
                text: "add".tr(),
                onPressed: () async {
                  isLoadingController.add(true);
                  await api.createDocument(
                    context,
                    collectionId: collectionLessons,
                    data: {
                      "parentId": user.choosenSemester,
                      "name": addLessonController.text,
                      "average": -99,
                      "emoji": _selectedEmoji
                    },
                  );

                  await getLessons(false);
                  Navigator.of(context).pop();
                  addLessonController.text = "";
                  isLoadingController.add(false);
                },
              ),
              Spacer(flex: 5),
            ],
          ),
        ),
      );
    });
  }

  updateLesson() {
    renameTestWeightController.text = selectedLessonName;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: primaryColor,
          ),
          backgroundColor: defaultBGColor,
          elevation: 0,
          title: Text("rename".tr(), style: appBarTextTheme),
          shape: defaultRoundedCorners(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    _selectedEmoji = "";
                  });
                },
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext subcontext) {
                      return Container(
                        height: 290,
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            EmojiChooser(
                              columns: ((() {
                                if (screenwidth > 1700) {
                                  return 35;
                                } else if (screenwidth > 1100) {
                                  return 45;
                                } else if (screenwidth > 900) {
                                  return 38;
                                } else if (screenwidth > 800) {
                                  return 30;
                                } else if (screenwidth > 700) {
                                  return 28;
                                } else if (screenwidth > 600) {
                                  return 25;
                                } else if (screenwidth > 500) {
                                  return 15;
                                } else if (screenwidth > 400) {
                                  return 15;
                                } else if (screenwidth < 400) {
                                  return 10;
                                }
                              })()),
                              onSelected: (_emoji) {
                                setState(() {
                                  _selectedEmoji = _emoji.char;
                                });

                                Navigator.of(subcontext).pop(_emoji);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ((() {
                  if (_selectedEmoji == "") {
                    return Text(
                      "no_emoji_choosed".tr(),
                      style: TextStyle(color: primaryColor),
                    );
                  } else {
                    return Text(
                      _selectedEmoji.toString(),
                      style: TextStyle(fontSize: 70),
                    );
                  }
                })()),
              ),
              Spacer(flex: 2),
              TextField(
                  controller: renameTestWeightController,
                  inputFormatters: [emojiRegex()],
                  textAlign: TextAlign.left,
                  decoration: inputDec(label: "lesson_name".tr())),
              SizedBox(
                height: 40,
              ),
              gradelyButton(
                text: "rename".tr(),
                onPressed: () async {
                  isLoadingController.add(true);
                  await api.updateDocument(context,
                      collectionId: collectionLessons,
                      documentId: selectedLesson,
                      data: {
                        "name": renameTestWeightController.text,
                        "emoji": _selectedEmoji
                      });
                  await getLessons(false);
                  Navigator.of(context).pop();

                  renameTestWeightController.text = "";
                  isLoadingController.add(false);
                },
              ),
              Spacer(flex: 5),
            ],
          ),
        ),
      );
    });
  }
}
