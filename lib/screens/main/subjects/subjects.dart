import "package:flutter/foundation.dart";
import "package:gradely2/components/controllers/semester_controller.dart";
import "package:gradely2/components/controllers/subject_controller.dart";
import "package:gradely2/components/controllers/user_controller.dart";
import "package:gradely2/components/utils/app.dart";
import "package:gradely2/components/utils/grades.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/components/widgets/dialogs.dart";
import "package:gradely2/components/widgets/loading.dart";
import "package:gradely2/main.dart";
import "package:gradely2/screens/auth/intro_screen.dart" as intro_screen;
import "package:gradely2/screens/main/subjects/create_subject.dart";
import "package:gradely2/screens/main/subjects/update_subject.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:universal_io/io.dart";
import "package:flutter/cupertino.dart" hide MenuItem;
import "package:flutter/material.dart" hide MenuItem;
import "package:flutter/scheduler.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:gradely2/screens/settings/settings.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";
import "package:url_launcher/url_launcher.dart";
import "../semesters/semesters.dart";
import "dart:math" as math;
import "package:easy_localization/easy_localization.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:contextual_menu/contextual_menu.dart";

double _averageOfSemester = 0 / -0;
double _averageOfSemesterPP = 0 / -0;

String switchedGradeType = user.gradeType;
late Subject selectedSubject;

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({Key? key}) : super(key: key);

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final SubjectController subjectController =
      SubjectController(navigatorKey.currentContext);
  final SemesterController semesterController =
      SemesterController(navigatorKey.currentContext);
  final UserController userController = UserController();

  List<Subject> _subjectList = [];
  Semester? currentSemester;
  double? _initialSemesterRound;

  Future<void> getSubjects({bool initalFetch = false}) async {
    if (initalFetch) setState(() => isLoading = true);
    _subjectList = await subjectController.list(getFromCache: initalFetch);
    try {
      currentSemester = await semesterController.getById(user.choosenSemester);
      _initialSemesterRound = currentSemester!.round;
    } catch (_) {
      if (await (internetConnection())) {
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
      double sum = 0;
      double ppSum = 0;
      double count = 0;
      for (var e in _subjectList) {
        if (e.average != -99) {
          sum += e.average;
          ppSum += getPluspoints(e.average)!;
          count = count + 1;
        }
        setState(() {
          _averageOfSemesterPP = ppSum;
          _averageOfSemester = sum / count;
        });
      }
    }
  }

  Future<Widget?> deleteSubject(index) {
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
                  launchUrl(Uri.parse("https://gradelyapp.com#download"));
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
    if (!(await (internetConnection()))) {
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
    userController.getUserInfo();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      noInternetWarning();
      webNotRecommendedPopUP();
      Future.delayed(
          Duration(milliseconds: 7000), () => askForInAppRating(context));
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
                                  PackageInfo packageInfo =
                                      await PackageInfo.fromPlatform();
                                  await settingsScreen(context,
                                      packageInfo: packageInfo);
                                  getSubjects();
                                }),
                          ))
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSemester!.name,
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
                                                setState(() => currentSemester!
                                                            .round ==
                                                        _initialSemesterRound
                                                    ? currentSemester!.round =
                                                        0.01
                                                    : currentSemester!.round =
                                                        _initialSemesterRound!);
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
                                                            currentSemester!
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
                              IconButton(
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
                          return subjectListTile(index);
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
                isCupertino ? CupertinoIcons.pen : Icons.edit_outlined,
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
                  isCupertino ? CupertinoIcons.delete : Icons.delete_outline,
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
              GestureDetector(
                onSecondaryTap: () => popUpContextualMenu(Menu(items: [
                  MenuItem(
                    onClick: (_) => deleteSubject(index),
                    label: "delete".tr(),
                  ),
                  MenuItem(
                      onClick: (_) => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UpdateSubject(
                                      subject: _subjectList[index],
                                    )),
                          ).then((_) => getSubjects()),
                      label: "edit".tr()),
                ])),
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
                        return roundGrade(_subjectList[index].average,
                            currentSemester!.round);
                      }
                    })(),
                  ),
                  onTap: () {
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
