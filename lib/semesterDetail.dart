import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/shared/CLASSES.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
import 'package:gradely/shared/VARIABLES..dart';
import 'package:gradely/shared/loading.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'auth/login.dart';
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
import 'package:emoji_chooser/emoji_chooser.dart';

String test =
    """{"sum":1,"documents":[{"\$id":"60f7176206ac6","\$collection":"60f40d1b66424","\$permissions":{"read":["*"],"write":["*"]},"name":"test semester","uid":"","lessons":[{"\$id":"60f71ed5b81ce","\$collection":"60f40d0ed5da4","\$permissions":[],"name":"test less","emoji":":*++","average":3},{"\$id":"60f72024f1d23","\$collection":"60f40d0ed5da4","\$permissions":{"read":["user:60f438e64c47b"],"write":["user:60f438e64c47b"]},"name":"1","emoji":"","average":2},{"\$id":"60f72057dae32","\$collection":"60f40d0ed5da4","\$permissions":{"read":["user:60f438e64c47b"],"write":["user:60f438e64c47b"]},"name":"2","emoji":"","average":1},{"\$id":"60f722de54bbd","\$collection":"60f40d0ed5da4","\$permissions":{"read":["user:60f438e64c47b"],"write":["user:60f438e64c47b"]},"name":"fdfd","average":-99,"emoji":""}]}]}""";
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

  appwriteDB(Function function) {}

  getLessons() async {
    lessonList = [];
    var response;
    

    response = await listDocuments(
        collection: collectionSemester,
        name: "lessonList",
        filters: ["\$id=${user.choosenSemester}"]);

    response = jsonDecode(response.toString())["documents"][0]["lessons"];

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
        print(emoji);
        setState(() {
          lessonList.add(Lesson(
              response[index]["\$id"],
              response[index]["name"],
              response[index]["emoji"],
              double.parse(response[index]["average"].toString())));
        });
      }
    }

    //getSemesteraverage
    double _sum = 0;
    double _ppSum = 0;
    double _count = 0;
    for (var e in lessonList) {
      if (e.average != -99) {
        _sum += e.average;
        _ppSum += getPluspoints(e.average);
        _count = _count + 1;
        setState(() {
          averageOfSemesterPP = _ppSum;
          averageOfSemester = _sum / _count;
          print(averageOfSemester);
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
    if (choosenSemesterName == "noSemesterChmoosed") {
      return LoadingScreen();
    } else {
      return Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: (() {
                                  if (gradesResult == "Durchschnitt") {
                                    if (averageOfSemester.isNaN) {
                                      return Text(
                                          "${'Notendurchschnitt'.tr()}: -",
                                          style:
                                              TextStyle(color: Colors.white));
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
                  preferredSize: Size(0, 120)),
              leading: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: IconButton(
                    icon: Icon(Icons.segment),
                    onPressed: () async {
                      HapticFeedback.lightImpact();

                      settingsScreen(context);
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
                            builder: (context) => ChooseSemester()),
                      );
                    }),
              ],
              shape: defaultRoundedCorners(),
            ),
          ];
        },
        body: ListView.builder(
          itemCount: lessonList.length,
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
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: IconSlideAction(
                          color: defaultColor,
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
                                          builder: (context) => HomeWrapper()),
                                      (Route<dynamic> route) => false,
                                    );

                                    selectedLesson = lessonList[index].id;
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                    child: Container(
                      decoration: whiteBoxDec(),
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
                            if (lessonList[index].average == -99) {
                              return "-";
                            } else if (gradesResult == "Pluspunkte") {
                              return getPluspoints(lessonList[index].average)
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
                                builder: (context) => LessonsDetail()),
                          );

                          selectedLesson = lessonList[index].id;
                          selectedLessonName = lessonList[index].name;
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
                } else {}
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

createLesson(String lessonName) async {
  Future result = database.createDocument(
    collectionId: collectionLessons,
    parentDocument: user.choosenSemester,
    parentProperty: "lessons",
    parentPropertyType: "append",
    data: {"name": lessonName, "average": -99, "emoji": selectedEmoji},
  );

  result.then((response) {
    print(response);
  }).catchError((error) {
    print(error.response);
  });
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
                } else {}
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
