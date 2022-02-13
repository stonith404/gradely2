import "package:flutter/foundation.dart";
import "package:gradely2/components/controllers/semester_controller.dart";
import "package:gradely2/components/controllers/subject_controller.dart";
import "package:gradely2/components/utils/app.dart";
import "package:gradely2/components/utils/grades.dart";
import "package:gradely2/components/utils/user.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/components/widgets/dialogs.dart";
import "package:gradely2/components/widgets/loading.dart";
import "package:gradely2/main.dart";
import "package:gradely2/screens/auth/intro_screen.dart" as intro_screen;
import "package:gradely2/screens/main/subjects/create_subject.dart";
import "package:gradely2/screens/main/subjects/update_subject.dart";
import "package:showcaseview/showcaseview.dart";
import "package:universal_io/io.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:gradely2/screens/settings/settings.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";
import "../semesters/semesters.dart";
import "dart:math" as math;
import "package:easy_localization/easy_localization.dart";
import "package:flutter_icons/flutter_icons.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:native_context_menu/native_context_menu.dart";

double _averageOfSemester = 0 / -0;
double _averageOfSemesterPP = 0 / -0;

String switchedGradeType = user.gradeType;
Subject selectedSubject;

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({Key key}) : super(key: key);

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final SubjectController subjectController =
      SubjectController(navigatorKey.currentContext);
  final SemesterController semesterController =
      SemesterController(navigatorKey.currentContext);

  List<Subject> _subjectList = [];
  Semester currentSemester;
  double _initialSemesterRound;

  // Every showcasw widget needs a GlobalKey
  final GlobalKey _showCase1 = GlobalKey();
  final GlobalKey _showCase2 = GlobalKey();
  final GlobalKey _showCase3 = GlobalKey();

  Future<void> getSubjects({bool initalFetch = false}) async {
    if (initalFetch) setState(() => isLoading = true);
    _subjectList = await subjectController.list(getFromCache: initalFetch);
    try {
      currentSemester = await semesterController.getById(user.choosenSemester);
    } catch (_) {
      if (await internetConnection()) {
        // If semester doesn't exist
        Navigator.pushNamedAndRemoveUntil(
          context,
          "semesters",
          (Route<dynamic> route) => false,
        );
      }
    }
    getSemesterAverage();
    setState(() {
      _subjectList;
      currentSemester;
    });
    setState(() => isLoading = false);
  }

  void getSemesterAverage() {
    if (_subjectList.isEmpty) {
      _averageOfSemesterPP = -99;
      _averageOfSemester = -99;
    } else {
      double _sum = 0;
      double _ppSum = 0;
      double _count = 0;
      for (var e in _subjectList) {
        if (e.average != -99) {
          _sum += e.average;
          _ppSum += getPluspoints(e.average);
          _count = _count + 1;
        }
        setState(() {
          _averageOfSemesterPP = _ppSum;
          _averageOfSemester = _sum / _count;
        });
      }
    }
  }

  Future<Widget> deleteSubject(index) {
    return gradelyDialog(
      context: context,
      title: "warning".tr(),
      text: "delete_confirmation".tr(args: [_subjectList[index].name]),
      actions: <Widget>[
        CupertinoButton(
          child: Text(
            "no".tr(),
            style: TextStyle(color: Theme.of(context).primaryColorDark),
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
            subjectController.delete(_subjectList[index].id);
            setState(() => _subjectList
                .removeWhere((item) => item.id == _subjectList[index].id));
            getSemesterAverage();
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  // Notify the user that Gradely 2 Web isn't recommended.
  void webNotRecommendedPopUP() {
    if (!(prefs.getBool("webNotRecommendedPopUp_viewed") ?? false) && kIsWeb) {
      gradelyDialog(
          context: context,
          title: "web_popup_title".tr(),
          text: "web_popup_description".tr(),
          actions: [
            TextButton(
                onPressed: () {
                  prefs.setBool("webNotRecommendedPopUp_viewed", true);
                  launchURL("https://gradelyapp.com#download");
                },
                child: Text("download".tr())),
            TextButton(
                onPressed: () {
                  prefs.setBool("webNotRecommendedPopUp_viewed", true);
                  Navigator.of(context).pop();
                },
                child: Text("Ok".tr()))
          ]);
    }
  }

  Future<void> noInternetWarning() async {
    if (!(await internetConnection())) {
      errorSuccessDialog(
          context: context,
          error: true,
          text: "no_network".tr(),
          title: "network_needed_title".tr());
    }
  }

  @override
  void initState() {
    super.initState();
    getSubjects(
        initalFetch: true); // Preload from cache to decrease loading time.
    getSubjects();
    getUserInfo();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      noInternetWarning();
      webNotRecommendedPopUP();
      // Show intro if didn't show before.
      if (!(user.showcaseViewed ?? false)) {
        Future.delayed(Duration(milliseconds: 1000), () {
          ShowCaseWidget.of(context)
              .startShowCase([_showCase1, _showCase2, _showCase3]);
        });
      } else {
        Future.delayed(Duration(milliseconds: 7000), () => askForInAppRating());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user.choosenSemester == "noSemesterChoosed") {
      return SemesterScreen();
    } else if (!user.emailVerification) {
      return intro_screen.Intro6();
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
                        title: SvgPicture.asset("assets/images/logo.svg",
                            color: Theme.of(context).primaryColorDark,
                            height: 30),
                        leading: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: IconButton(
                              icon: Icon(Icons.segment,
                                  color: Theme.of(context).primaryColorDark),
                              onPressed: () async {
                                await settingsScreen(context);
                                getSubjects();
                              }),
                        ),
                        actions: [
                          Showcase(
                            key: _showCase1,
                            title: "semesters".tr(),
                            description: "showcase_semester_button".tr(),
                            disableAnimation: false,
                            shapeBorder: CircleBorder(),
                            radius: BorderRadius.all(Radius.circular(40)),
                            child: IconButton(
                                icon: Icon(Icons.switch_left,
                                    color: Theme.of(context).primaryColorDark),
                                onPressed: () async {
                                  Navigator.pushNamed(context, "semesters")
                                      .then((value) => getSubjects());
                                }),
                          ),
                        ],
                      ),
                    ];
                  },
                  body: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: ListView(padding: EdgeInsets.zero, children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
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
                                    currentSemester.name,
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (user.gradeType == "av") {
                                                setState(() => currentSemester
                                                            .round ==
                                                        _initialSemesterRound
                                                    ? currentSemester.round =
                                                        0.01
                                                    : currentSemester.round =
                                                        _initialSemesterRound);
                                              } else {
                                                setState(() =>
                                                    switchedGradeType = "av");
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Text("Ø",
                                                    style: TextStyle(
                                                      fontSize: 19,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    )),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    _averageOfSemester.isNaN ||
                                                            _averageOfSemester ==
                                                                -99
                                                        ? "-"
                                                        : roundGrade(
                                                            _averageOfSemester,
                                                            currentSemester
                                                                .round),
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() =>
                                                  switchedGradeType = "pp");
                                            },
                                            child: Row(
                                              children: [
                                                user.gradeType == "av"
                                                    ? Container()
                                                    : Icon(
                                                        Icons
                                                            .add_circle_outline_outlined,
                                                        size: 19,
                                                        color: Theme.of(context)
                                                            .primaryColorLight),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                user.gradeType == "av"
                                                    ? Container()
                                                    : Text(
                                                        _averageOfSemester
                                                                    .isNaN ||
                                                                _averageOfSemester ==
                                                                    -99
                                                            ? "0"
                                                            : _averageOfSemesterPP
                                                                .toString(),
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorLight,
                                                        ))
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                              Spacer(flex: 1),
                              Showcase(
                                key: _showCase2,
                                title: "subjects".tr(),
                                description: "showcase_add_subject_button".tr(),
                                disableAnimation: false,
                                shapeBorder: CircleBorder(),
                                radius: BorderRadius.all(Radius.circular(40)),
                                child: IconButton(
                                    icon: Icon(Icons.add),
                                    color: Theme.of(context).primaryColorLight,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        GradelyPageRoute(
                                            builder: (context) =>
                                                CreateSubject()),
                                      ).then((value) => getSubjects());
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Platform.isMacOS || Platform.isWindows
                          ? SizedBox(
                              height: 10,
                            )
                          : Container(),
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _subjectList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return index == 0 && !user.showcaseViewed
                              ? Showcase(
                                  key: _showCase3,
                                  title: "grades".tr(),
                                  description:
                                      Platform.isWindows || Platform.isMacOS
                                          ? "showcase_subject_list_desktop".tr()
                                          : "showcase_subject_list".tr(),
                                  disableAnimation: false,
                                  shapeBorder: CircleBorder(),
                                  radius: BorderRadius.all(Radius.circular(15)),
                                  child: subjectListTile(index))
                              : subjectListTile(index);
                        },
                      ),
                    ]),
                  ),
                ),
              )));
    }
  }

  Widget subjectListTile(index) {
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
              color: Theme.of(context).primaryColorDark,
              iconWidget: Icon(
                FontAwesome5Solid.pencil_alt,
                color: Theme.of(context).primaryColorLight,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateSubject(subject: _subjectList[index])),
                ).then((_) => getSubjects());
              },
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: IconSlideAction(
                color: Theme.of(context).primaryColorDark,
                iconWidget: Icon(
                  FontAwesome5.trash_alt,
                  color: Theme.of(context).primaryColorLight,
                ),
                onTap: () => deleteSubject(index)),
          ),
        ],
        child: Container(
          decoration: listContainerDecoration(context,
              index: index, list: _subjectList),
          child: Column(
            children: [
              ContextMenuRegion(
                onItemSelected: (item) => {item.onSelected()},
                menuItems: [
                  MenuItem(
                    onSelected: () => deleteSubject(index),
                    title: "delete".tr(),
                  ),
                  MenuItem(
                      onSelected: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UpdateSubject(
                                      subject: _subjectList[index],
                                    )),
                          ).then((_) => getSubjects()),
                      title: "edit".tr()),
                ],
                child: ListTile(
                  title: Text(
                    _subjectList[index].name,
                  ),
                  trailing: Text(
                    (() {
                      if (_subjectList[index].average == -99) {
                        return "-";
                      } else if (user.gradeType == "pp" &&
                          switchedGradeType == "pp") {
                        return getPluspoints(_subjectList[index].average)
                            .toString();
                      } else {
                        return roundGrade(
                            _subjectList[index].average, currentSemester.round);
                      }
                    })(),
                  ),
                  onTap: () {
                    if (!user.showcaseViewed) {
                      ShowCaseWidget.of(context).completed(_showCase3);
                    }
                    selectedSubject = _subjectList[index];
                    Navigator.pushNamed(context, "grades").then((value) {
                      getSubjects();
                    });
                  },
                ),
              ),
              listDivider(),
            ],
          ),
        ));
  }
}
