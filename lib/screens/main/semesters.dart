import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely2/main.dart';
import 'package:gradely2/shared/CLASSES.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:gradely2/shared/loading.dart';
import 'package:easy_localization/easy_localization.dart';

bool isChecked = false;
String choosenSemester;
Semester _selectedSemester;

class SemesterScreen extends StatefulWidget {
  @override
  _SemesterScreenState createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  getSemesters() async {
    setState(() => isLoading = true);
    semesterList = [];

    semesterList = (await api.listDocuments(
            collection: collectionSemester,
            name: "semesterList",
            filters: ["parentId=${user.dbID}"]))["documents"]
        .map((r) => Semester(r["\$id"], r["name"], r["round"]))
        .toList();
    setState(() => isLoading = false);
  }

  saveChoosenSemester(String _choosenSemester) async {
    await api.updateDocument(context,
        collectionId: collectionUser,
        documentId: user.dbID,
        data: {"choosenSemester": _choosenSemester});
  }

  @override
  void initState() {
    super.initState();
    getSemesters();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        title: Text("Semester", style: appBarTextTheme),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              GradelyPageRoute(builder: (context) => addSemester()),
            );
          }),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          isLoading
              ? GradelyLoadingIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: semesterList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
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
                                color: primaryColor,
                                iconWidget: Icon(
                                  FontAwesome5Solid.pencil_alt,
                                  color: frontColor(),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    GradelyPageRoute(
                                        builder: (context) => updateSemester()),
                                  );

                                  _selectedSemester = semesterList[index];
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
                                onTap: () {
                                  return gradelyDialog(
                                    context: context,
                                    title: "warning".tr(),
                                    text:
                                        '${"delete_confirmation_p1".tr()} "${semesterList[index].name}" ${"delete_confirmation_p2".tr()}',
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
                                        onPressed: () {
                                          if (user.choosenSemester ==
                                              semesterList[index].id) {
                                            saveChoosenSemester(
                                                "noSemesterChoosed");
                                          }
                                          api.deleteDocument(context,
                                              collectionId: collectionSemester,
                                              documentId:
                                                  semesterList[index].id);

                                          setState(() {
                                            semesterList.removeWhere((item) =>
                                                item.id ==
                                                semesterList[index].id);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                          child: Container(
                            decoration: listContainerDecoration(
                                index: index, list: semesterList),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    semesterList[index].name,
                                  ),
                                  trailing: IconButton(
                                      color: primaryColor,
                                      icon: Icon(Icons.arrow_forward),
                                      onPressed: () async {
                                        await saveChoosenSemester(
                                            semesterList[index].id);
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          GradelyPageRoute(
                                              builder: (context) =>
                                                  HomeWrapper()),
                                          (Route<dynamic> route) => false,
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  updateSemester() {
    renameSemesterController.text = _selectedSemester.name;
    double roundTo = _selectedSemester.round ?? 0.01;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: primaryColor,
          ),
          backgroundColor: defaultBGColor,
          elevation: 0,
          title: Text(
            "edit_semester".tr(),
            style: appBarTextTheme,
          ),
          shape: defaultRoundedCorners(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                  controller: renameSemesterController,
                  textAlign: TextAlign.left,
                  inputFormatters: [emojiRegex()],
                  decoration: inputDec(label: "Semester Name")),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("edit_semester_round".tr()),
                  SizedBox(
                    width: 10,
                  ),
                  CupertinoSlidingSegmentedControl(
                      groupValue: roundTo,
                      children: {
                        0.1: Text("0.1"),
                        0.5: Text("0.5"),
                        0.01: Text("0.01")
                      },
                      onValueChanged: (n) => {setState(() => roundTo = n)}),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              gradelyButton(
                text: "rename".tr(),
                onPressed: () async {
                  isLoadingController.add(true);
                  await api.updateDocument(context,
                      collectionId: collectionSemester,
                      documentId: _selectedSemester.id,
                      data: {
                        "name": renameSemesterController.text,
                        "round": roundTo
                      });

                  await getSemesters();
                  Navigator.of(context).pop();

                  renameSemesterController.text = "";
                  isLoadingController.add(false);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  addSemester() {
    double roundTo = 0.01;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: primaryColor,
          ),
          elevation: 0,
          backgroundColor: defaultBGColor,
          title: Text("add_semester".tr(), style: appBarTextTheme),
          shape: defaultRoundedCorners(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                  inputFormatters: [emojiRegex()],
                  controller: addSemesterController,
                  textAlign: TextAlign.left,
                  decoration: inputDec(label: "Semester Name")),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("edit_semester_round".tr()),
                  SizedBox(
                    width: 10,
                  ),
                  CupertinoSlidingSegmentedControl(
                      groupValue: roundTo,
                      children: {
                        0.1: Text("0.1"),
                        0.5: Text("0.5"),
                        0.01: Text("0.01")
                      },
                      onValueChanged: (n) => {setState(() => roundTo = n)}),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              gradelyButton(
                  text: "add".tr(),
                  onPressed: () async {
                    isLoadingController.add(true);
                    await getUserInfo();
                    await api.createDocument(context,
                        collectionId: collectionSemester,
                        data: {
                          "parentId": user.dbID,
                          "name": addSemesterController.text,
                          "round": roundTo
                        });

                    await getSemesters();
                    Navigator.of(context).pop();

                    isLoadingController.add(false);
                  })
            ],
          ),
        ),
      );
    });
  }
}
