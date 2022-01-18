import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely2/shared/MODELS.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:gradely2/shared/loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:native_context_menu/native_context_menu.dart';

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
            queries: [Query.equal("parentId", user.dbID)]))
        .map((r) => Semester(r["\$id"], r["name"], r["round"]))
        .toList();
    setState(() => isLoading = false);
  }

  saveChoosenSemester(String _choosenSemester) async {
    user.choosenSemester = _choosenSemester;
    await api.updateDocument(context,
        collectionId: collectionUser,
        documentId: user.dbID,
        data: {"choosenSemester": _choosenSemester});
  }

  deleteSemester(index) {
    return gradelyDialog(
      context: context,
      title: "warning".tr(),
      text: "delete_confirmation".tr(args: [semesterList[index].name]),
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
          onPressed: () {
            if (user.choosenSemester == semesterList[index].id) {
              saveChoosenSemester("noSemesterChoosed");
            }
            api.deleteDocument(context,
                collectionId: collectionSemester,
                documentId: semesterList[index].id);

            setState(() {
              semesterList
                  .removeWhere((item) => item.id == semesterList[index].id);
            });
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  duplicateSemester(index) {
    gradelyDialog(
        context: context,
        title: "duplicate_semester".tr(),
        text: "duplicate_semester_text".tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("cancel".tr()),
          ),
          TextButton(
              onPressed: () async {
                var lessonsList = (await api.listDocuments(
                        collection: collectionLessons,
                        name: "lessonList_${semesterList[index].id}",
                        queries: [
                      Query.equal("parentId", semesterList[index].id)
                    ]))
                    .map((r) => Lesson(r["\$id"], r["name"], r["emoji"],
                        double.parse(r["average"].toString())))
                    .toList();

                String newSemester = (await api.createDocument(context,
                        collectionId: collectionSemester,
                        data: {
                      "parentId": user.dbID,
                      "name": semesterList[index].name + " - ${'copy'.tr()}",
                      "round": semesterList[index].round
                    }))
                    .$id;

                for (var i = 0; i < lessonsList.length; i++) {
                  api.createDocument(context,
                      collectionId: collectionLessons,
                      data: {
                        "parentId": newSemester,
                        "name": lessonsList[i].name,
                        "average": -99,
                        "emoji": lessonsList[i].emoji
                      });
                }
                Navigator.of(context).pop();
                getSemesters();
              },
              child: Text("continue".tr()))
        ]);
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
        title: Text("Semester"),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColorDark,
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
                                  color: Theme.of(context).primaryColorDark,
                                  iconWidget: Icon(
                                    FontAwesome5Solid.clone,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  onTap: () => duplicateSemester(index)),
                            ),
                            IconSlideAction(
                              color: Theme.of(context).primaryColorDark,
                              iconWidget: Icon(
                                FontAwesome5Solid.pencil_alt,
                                color: Theme.of(context).primaryColorLight,
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
                                  onTap: () => deleteSemester(index)),
                            ),
                          ],
                          child: Container(
                            decoration: listContainerDecoration(context,
                                index: index, list: semesterList),
                            child: Column(
                              children: [
                                ContextMenuRegion(
                                  onItemSelected: (item) => {item.onSelected()},
                                  menuItems: [
                                    MenuItem(
                                      onSelected: () => deleteSemester(index),
                                      title: 'delete'.tr(),
                                    ),
                                    MenuItem(
                                        onSelected: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    updateSemester()),
                                          );
                                          _selectedSemester =
                                              semesterList[index];
                                        },
                                        title: 'edit'.tr()),
                                    MenuItem(
                                        onSelected: () =>
                                            duplicateSemester(index),
                                        title: 'duplicate'.tr()),
                                  ],
                                  child: ListTile(
                                    title: Text(
                                      semesterList[index].name,
                                    ),
                                    trailing: IconButton(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        icon: Icon(Icons.arrow_forward),
                                        onPressed: () async {
                                          await saveChoosenSemester(
                                              semesterList[index].id);
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            "subjects",
                                            (Route<dynamic> route) => false,
                                          );
                                        }),
                                  ),
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
          title: Text(
            "edit_semester".tr(),
          ),
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
                  decoration: inputDec(context, label: "Semester Name")),
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
                text: "save".tr(),
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
          title: Text("add_semester".tr()),
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
                  decoration: inputDec(context, label: "Semester Name")),
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
                    addSemesterController.text = "";
                    isLoadingController.add(false);
                  })
            ],
          ),
        ),
      );
    });
  }
}
