import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/shared/loading.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'userAuth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared/defaultWidgets.dart';
import 'chooseSemester.dart';
import 'dart:math' as math;
import 'settings/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:emoji_chooser/emoji_chooser.dart';
import 'settings/gradelyPlus.dart';

double screenwidth = 0;
bool darkmode = false;
List semesterAveragePP = [];
List emojiList = [];
var emoji = "";
String selectedEmoji = "";

class HomeSite extends StatefulWidget {
  const HomeSite({
    Key key,
  }) : super(key: key);

  @override
  _HomeSiteState createState() => _HomeSiteState();
}

class _HomeSiteState extends State<HomeSite> {
  pushNotification() {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
    });
// Asks permission for push notifcations in ios
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
  }

  getLessons() async {
    await getUIDDocuments();

    if (uidDB.data()['choosenSemester'] == null) {
      FirebaseFirestore.instance
          .collection('userData')
          .doc(auth.currentUser.uid)
          .update({'choosenSemester': 'noSemesterChoosed'});
    } else {
      choosenSemester = uidDB.data()['choosenSemester'];
      getUIDDocuments();
    }

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(
            'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
        .orderBy("average", descending: true)
        .get();
    List<DocumentSnapshot> documents = result.docs;

    courseList = [];
    courseListID = [];

    allAverageList = [];
    allAverageListPP = [];
    semesterAveragePP = [];
    emojiList = [];

    setState(() {
      documents.forEach((data) {
        courseList.add(data["name"]);
        courseListID.add(data.id);
        allAverageList.add(data["average"]);
        try {
          emojiList.add(data["emoji"]);
        } catch (e) {
          emojiList.add("");
        }
      });

      documents.forEach((data) {
        getPluspointsallAverageList(data["average"]);
        if (data["average"].isNaN) {
          allAverageListPP.add(0.toString());
          semesterAveragePP.add(0);
        } else {
          allAverageListPP.add(plusPointsallAverageList.toString());
          semesterAveragePP.add(plusPointsallAverageList);
        }
      });
    });
    //getSemesteraverage
    num _pp = 0;

    for (num e in semesterAveragePP) {
      _pp += e;
    }
    setState(() {
      averageOfSemesterPP = _pp;
    });

    //get average of all

    double _sum = 0;
    double _anzahl = 0;
    for (num e in allAverageList) {
      if (e.isNaN) {
      } else {
        _sum += e;
        _anzahl = _anzahl + 1;
        setState(() {
          averageOfSemester = _sum / _anzahl;
        });
      }
    }
  }

  darkModeColorChanger() {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      setState(() {
        bwColor = Colors.grey[850];
        wbColor = Colors.white;
        darkmode = true;
      });
    } else {
      bwColor = Colors.white;
      wbColor = Colors.grey[850];
      darkmode = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getLessons();
    pushNotification();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenwidth = MediaQuery.of(context).size.width;
    darkModeColorChanger();
    if (choosenSemesterName == "noSemesterChoosed") {
      return LoadingScreen();
    } else {
      return Scaffold(
          drawer: Drawer(),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: defaultColor,
                  forceElevated: true,
                  title: Image.asset(
                    'assets/images/iconT.png',
                    height: 60,
                  ),
                  bottom: PreferredSize(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  choosenSemesterName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 25,
                                      color: Colors.white),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                    child: (() {
                                      if (gradesResult == "Durchschnitt") {
                                        if (averageOfSemester.isNaN) {
                                          return Text(
                                              "${'Notendurchschnitt'.tr()}: -",
                                              style: TextStyle(
                                                  color: Colors.white));
                                        }
                                        return Text(
                                            "${'Notendurchschnitt'.tr()}: ${averageOfSemester.toStringAsFixed(2)}",
                                            style:
                                                TextStyle(color: Colors.white));
                                      } else if (averageOfSemester.isNaN) {
                                        return Text(
                                            "${'Pluspunkte'.tr()}: ${averageOfSemesterPP.toStringAsFixed(2)} / ${'Notendurchschnitt'.tr()}: -",
                                            style:
                                                TextStyle(color: Colors.white));
                                      } else {
                                        return Text(
                                            "${'Pluspunkte'.tr()}: ${averageOfSemesterPP.toStringAsFixed(2)} / ${'Notendurchschnitt'.tr()}: ${averageOfSemester.toStringAsFixed(2)}",
                                            style:
                                                TextStyle(color: Colors.white));
                                      }
                                    }())),
                              ],
                            ),
                          ),
                          Spacer(flex: 1),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 15, 10),
                            child: IconButton(
                                icon: Icon(Icons.add),
                                color: Colors.white,
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => addLesson()),
                                  );
                                }),
                          ),
                        ],
                      ),
                      preferredSize: Size(0, 130)),
                  leading: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: IconButton(
                        icon: Icon(Icons.segment),
                        onPressed: () async {
                          HapticFeedback.lightImpact();

                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                duration: Duration(milliseconds: 150),
                                child: SettingsPage()),
                          );
                        }),
                  ),
                  floating: true,
                  actions: [
                    IconButton(
                        icon: Icon(Icons.switch_left),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => chooseSemester()),
                          );
                        }),
                  ],
                  shape: defaultRoundedCorners(),
                ),
              ];
            },
            body: ListView.builder(
              itemCount: courseListID.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 5, 8, 0),
                      child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        secondaryActions: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            child: IconSlideAction(
                              color: defaultColor,
                              iconWidget: Icon(FontAwesome5Solid.pencil_alt),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => updateLesson()),
                                );
                                selectedLessonName = courseList[index];
                                selectedEmoji = emojiList[index];
                                selectedLesson = courseListID[index];
                              },
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            child: IconSlideAction(
                              color: defaultColor,
                              iconWidget: Icon(FontAwesome5.trash_alt),
                              onTap: () {
                                gradelyDialog(
                                  context: context,
                                  title: "Achtung".tr(),
                                  text:
                                      "${'Bist du sicher, dass du'.tr()} ${courseList[index]} ${'löschen willst?'.tr()}",
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        "Nein".tr(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Löschen".tr(),
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection(
                                                'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
                                            .doc(courseListID[index])
                                            .set({});
                                        FirebaseFirestore.instance
                                            .collection(
                                                'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
                                            .doc(courseListID[index])
                                            .delete();
                                        HapticFeedback.heavyImpact();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeWrapper()),
                                          (Route<dynamic> route) => false,
                                        );

                                        selectedLesson = courseListID[index];
                                      },
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                        child: Container(
                          decoration: boxDec(),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(emojiList[index] + "  ",
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
                                  courseList[index],
                                ),
                              ],
                            ),
                            trailing: Text(
                              (() {
                                if (allAverageList[index].isNaN) {
                                  return "-";
                                } else if (gradesResult == "Pluspunkte") {
                                  return allAverageListPP[index];
                                } else {
                                  return allAverageList[index]
                                      .toStringAsFixed(2);
                                }
                              })(),
                            ),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LessonsDetail()),
                              );

                              setState(() {
                                selectedLesson = courseListID[index];
                                selectedLessonName = courseList[index];
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ));
    }
  }
}

var courseList = [];

class addLesson extends StatefulWidget {
  @override
  _addLessonState createState() => _addLessonState();
}

class _addLessonState extends State<addLesson> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeWrapper()),
              );
            }),
        backgroundColor: defaultColor,
        title: Text("Fach hinzufügen".tr()),
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
                  selectedEmoji = "";
                });
              },
              onTap: () {
                if (gradelyPlus) {
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
                                  selectedEmoji = _emoji.char;
                                });

                                Navigator.of(subcontext).pop(_emoji);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GradelyPlus()),
                  );
                }
              },
              child: ((() {
                if (selectedEmoji == "") {
                  return Text(
                    "no emoji".tr(),
                    style: TextStyle(color: defaultColor),
                  );
                } else {
                  return Text(
                    selectedEmoji.toString(),
                    style: TextStyle(fontSize: 70),
                  );
                }
              })()),
            ),
            Spacer(flex: 2),
            TextField(
                inputFormatters: [EmojiRegex()],
                controller: addLessonController,
                textAlign: TextAlign.left,
                decoration: inputDec("Fach Name".tr())),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: defaultColor,
              ),
              child: Text("hinzufügen".tr()),
              onPressed: () {
                createLesson(addLessonController.text);
                HapticFeedback.mediumImpact();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeWrapper()),
                  (Route<dynamic> route) => false,
                );

                addLessonController.text = "";
                courseList = [];
              },
            ),
            Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}

createLesson(String lessonName) {
  CollectionReference gradesCollection = FirebaseFirestore.instance.collection(
      'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/');
  gradesCollection.doc().set(
    {
      "name": lessonName,
      "average": 0 / -0,
      "emoji": selectedEmoji
    }, //generate NaN
  );
}

class updateLesson extends StatefulWidget {
  @override
  _updateLessonState createState() => _updateLessonState();
}

class _updateLessonState extends State<updateLesson> {
  @override
  Widget build(BuildContext context) {
    renameTestWeightController.text = selectedLessonName;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeWrapper()),
              );
            }),
        backgroundColor: defaultColor,
        title: Text("Fach unbenennen".tr()),
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
                  selectedEmoji = "";
                });
              },
              onTap: () {
                if (gradelyPlus) {
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
                                  selectedEmoji = _emoji.char;
                                });

                                Navigator.of(subcontext).pop(_emoji);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GradelyPlus()),
                  );
                }
              },
              child: ((() {
                if (selectedEmoji == "") {
                  return Text(
                    "no emoji".tr(),
                    style: TextStyle(color: defaultColor),
                  );
                } else {
                  return Text(
                    selectedEmoji.toString(),
                    style: TextStyle(fontSize: 70),
                  );
                }
              })()),
            ),
            Spacer(flex: 2),
            TextField(
                controller: renameTestWeightController,
                inputFormatters: [EmojiRegex()],
                textAlign: TextAlign.left,
                decoration: inputDec("Fach Name".tr())),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: defaultColor,
              ),
              child: Text("unbenennen".tr()),
              onPressed: () {
                updateLessonF(renameTestWeightController.text);
                HapticFeedback.mediumImpact();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeWrapper()),
                  (Route<dynamic> route) => false,
                );

                renameTestWeightController.text = "";
                courseList = [];
              },
            ),
            Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}

updateLessonF(String lessonUpdate) {
  FirebaseFirestore.instance
      .collection('userData')
      .doc(auth.currentUser.uid)
      .collection('semester')
      .doc(choosenSemester)
      .collection('lessons')
      .doc(selectedLesson)
      .update({"name": lessonUpdate, "emoji": selectedEmoji});
}
