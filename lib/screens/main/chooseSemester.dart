import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely2/main.dart';
import 'package:gradely2/screens/main/semesterDetail.dart';
import 'package:gradely2/shared/CLASSES.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:gradely2/shared/defaultWidgets.dart';
import 'package:gradely2/shared/loading.dart';
import 'package:easy_localization/easy_localization.dart';

bool isChecked = false;
String choosenSemester;
Semester _selectedSemester;

class ChooseSemester extends StatefulWidget {
  @override
  _ChooseSemesterState createState() => _ChooseSemesterState();
}

class _ChooseSemesterState extends State<ChooseSemester> {
  _getSemesters() async {
    setState(() => isLoading = true);
    semesterList = [];
    var response;

    response = await listDocuments(
        collection: collectionUser,
        name: "semesterList",
        filters: ["uid=${user.id}"]);
    response = jsonDecode(response.toString())["documents"][0]["semesters"];
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
        setState(() {
          semesterList.add(Semester(
            response[index]["\$id"],
            response[index]["name"],
          ));
        });
      }
    }
    setState(() => isLoading = false);
  }

  saveChoosenSemester(String _choosenSemester) async {
    await database.updateDocument(
        collectionId: collectionUser,
        documentId: user.dbID,
        data: {"choosenSemester": _choosenSemester});
  }

  @override
  void initState() {
    super.initState();
    _getSemesters();
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
              MaterialPageRoute(builder: (context) => addSemester()),
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
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
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
                                  color: Colors.white,
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
                                          noNetworkDialog(context);
                                          database.deleteDocument(
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
                                        choosenSemester =
                                            semesterList[index].id;
                                        choosenSemesterName =
                                            semesterList[index].name;
                                        await saveChoosenSemester(
                                            choosenSemester);

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        title: Text(
          "rename_semester".tr(),
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
              height: 40,
            ),
            gradelyButton(
              text: "rename".tr(),
              onPressed: () async {
                isLoadingController.add(true);
                noNetworkDialog(context);
                await database.updateDocument(
                    collectionId: collectionSemester,
                    documentId: _selectedSemester.id,
                    data: {"name": renameSemesterController.text});

                await _getSemesters();
                Navigator.of(context).pop();

                renameSemesterController.text = "";
                isLoadingController.add(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  addSemester() {
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                inputFormatters: [emojiRegex()],
                controller: addSemesterController,
                textAlign: TextAlign.left,
                decoration: inputDec(label: "Semester Name")),
            SizedBox(
              height: 20,
            ),
            gradelyButton(
                text: "add".tr(),
                onPressed: () async {
                  isLoadingController.add(true);
                  noNetworkDialog(context);
                  await getUserInfo();
                  await database.createDocument(
                      collectionId: collectionSemester,
                      parentDocument: user.dbID,
                      parentProperty: "semesters",
                      parentPropertyType: "append",
                      data: {"name": addSemesterController.text});

                  await _getSemesters();
                  Navigator.of(context).pop();

                  isLoadingController.add(false);
                })
          ],
        ),
      ),
    );
  }
}
