import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/GRADELY_OLD/shared/CLASSES.dart';
import 'package:gradely/GRADELY_OLD/shared/VARIABLES..dart';
import 'package:gradely/GRADELY_OLD/shared/loading.dart';
import 'package:gradely/GRADELY_OLD/LessonsDetail.dart';
import 'package:gradely/GRADELY_OLD/data.dart';
import 'package:gradely/GRADELY_OLD/userAuth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/GRADELY_OLD/shared/defaultWidgets.dart';
import 'package:gradely/GRADELY_OLD/chooseSemester.dart';
import 'dart:math' as math;
import 'package:gradely/GRADELY_OLD/settings/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:emoji_chooser/emoji_chooser.dart';

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

    if (uidDB.get('choosenSemester') == null) {
      FirebaseFirestore.instance
          .collection('userData')
          .doc(auth.currentUser.uid)
          .update({'choosenSemester': 'noSemesterChoosed'});
    } else {
      choosenSemester = uidDB.get('choosenSemester');
      setState(() {
        getUIDDocuments();
      });
    }

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(
            'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
        .orderBy("average", descending: true)
        .get();
    List<DocumentSnapshot> documents = result.docs;

    setState(() {
      lessonList = [];

      allAverageListPP = [];
      semesterAveragePP = [];
      emojiList = [];
      documents.forEach((data) {
        String emoji = "";
        try {
          emoji = (data["emoji"]);
        } catch (e) {
          emoji = "";
        }

        lessonList.add(
          Lesson(data["name"], data.id, data["average"], emoji),
        );
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
    darkModeColorChanger(context);
    buttonDisabled = false;
    if (choosenSemesterName == "noSemesterChoosed") {
      return LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: defaultBGColor,
          elevation: 0,
          title: Image.asset(
            'assets/images/iconT.png',
            height: 60,
          ),
          leading: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: IconButton(
                icon: Icon(Icons.segment, color: primaryColor),
                onPressed: () async {
                  HapticFeedback.lightImpact();

                  settingsScreen(context);
                }),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.switch_left, color: primaryColor),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseSemester()),
                  );
                }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    )),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: (() {
                                if (gradesResult == "Durchschnitt") {
                                  if (averageOfSemester.isNaN) {
                                    return Text(
                                        "${'Notendurchschnitt'.tr()}: -",
                                        style: TextStyle(color: Colors.white));
                                  }
                                  return Text(
                                      "${'Notendurchschnitt'.tr()}: ${averageOfSemester.toStringAsFixed(2)}",
                                      style: TextStyle(color: Colors.white));
                                } else if (averageOfSemester.isNaN) {
                                  return Text(
                                      "${'Pluspunkte'.tr()}: ${averageOfSemesterPP.toStringAsFixed(2)} / ${'Notendurchschnitt'.tr()}: -",
                                      style: TextStyle(color: Colors.white));
                                } else {
                                  return Text(
                                      "${'Pluspunkte'.tr()}: ${averageOfSemesterPP.toStringAsFixed(2)} / ${'Notendurchschnitt'.tr()}: ${averageOfSemester.toStringAsFixed(2)}",
                                      style: TextStyle(color: Colors.white));
                                }
                              }())),
                        ],
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
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: lessonList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: (() {
                        if (index == 0) {
                          return BoxDecoration(
                              color: bwColor,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ));
                        } else if (index == lessonList.length - 1) {
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
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                child: IconSlideAction(
                                  color: primaryColor,
                                  iconWidget: Icon(
                                    FontAwesome5Solid.pencil_alt,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => updateLesson()),
                                    );
                                    selectedLessonName = lessonList[index].name;
                                    selectedEmoji = lessonList[index].emoji;
                                    selectedLesson = lessonList[index].id;
                                  },
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                child: IconSlideAction(
                                  color: primaryColor,
                                  iconWidget: Icon(
                                    FontAwesome5.trash_alt,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    gradelyDialog(
                                      context: context,
                                      title: "Achtung".tr(),
                                      text:
                                          '${'Bist du sicher, dass du'.tr()} "${lessonList[index].name}" ${'löschen willst?'.tr()}',
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                            "Nein".tr(),
                                            style: TextStyle(color: wbColor),
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
                                                .doc(lessonList[index].id)
                                                .set({});
                                            FirebaseFirestore.instance
                                                .collection(
                                                    'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
                                                .doc(lessonList[index].id)
                                                .delete();
                                            HapticFeedback.heavyImpact();
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeWrapper()),
                                              (Route<dynamic> route) => false,
                                            );

                                            selectedLesson =
                                                lessonList[index].id;
                                          },
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                            child: Container(
                              child: Column(
                                children: [
                                  ListTile(
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
                                        if (lessonList[index].average.isNaN) {
                                          return "-";
                                        } else if (gradesResult ==
                                            "Pluspunkte") {
                                          return getPluspoints(
                                                  lessonList[index].average)
                                              .toString();
                                        } else {
                                          return lessonList[index]
                                              .average
                                              .toStringAsFixed(2);
                                        }
                                      })(),
                                    ),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LessonsDetail()),
                                      );

                                      selectedLesson = lessonList[index].id;
                                      selectedLessonName =
                                          lessonList[index].name;
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 35.0),
                                    child: Divider(
                                      thickness: 0.7,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
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
        backgroundColor: primaryColor,
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
                } else {}
              },
              child: ((() {
                if (selectedEmoji == "") {
                  return Text(
                    "no emoji".tr(),
                    style: TextStyle(color: primaryColor),
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
                primary: primaryColor,
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
        backgroundColor: primaryColor,
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
                } else {}
              },
              child: ((() {
                if (selectedEmoji == "") {
                  return Text(
                    "no emoji".tr(),
                    style: TextStyle(color: primaryColor),
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
                primary: primaryColor,
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
