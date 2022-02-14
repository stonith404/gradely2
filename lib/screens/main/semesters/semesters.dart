import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:gradely2/components/controllers/semester_controller.dart";
import "package:gradely2/components/utils/app.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/components/widgets/dialogs.dart";
import "package:gradely2/components/widgets/loading.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";
import "package:easy_localization/easy_localization.dart";
import "package:gradely2/main.dart";
import "package:gradely2/screens/main/semesters/create_semester.dart";
import "package:gradely2/screens/main/semesters/update_semester.dart";
import "package:native_context_menu/native_context_menu.dart";

class SemesterScreen extends StatefulWidget {
  const SemesterScreen({Key? key}) : super(key: key);

  @override
  _SemesterScreenState createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  SemesterController semesterController =
      SemesterController(navigatorKey.currentContext);
  List<Semester> _semesterList = [];

  Future<void> getSemsters() async {
    setState(() => isLoading = true);
    _semesterList = await semesterController.list();
    setState(() => _semesterList);
    setState(() => isLoading = false);
  }

  deleteSemester(int index) {
    return gradelyDialog(
      context: context,
      title: "warning".tr(),
      text: "delete_confirmation".tr(args: [_semesterList[index].name]),
      actions: <Widget>[
        CupertinoButton(
            child: Text(
              "no".tr(),
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            onPressed: () => Navigator.of(context).pop()),
        CupertinoButton(
          child: Text(
            "delete".tr(),
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            semesterController.delete(_semesterList[index].id);
            setState(() => _semesterList
                .removeWhere((item) => item.id == _semesterList[index].id));
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  duplicateSemester(int index) {
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
                await semesterController
                    .duplicateSemester(_semesterList[index]);
                getSemsters();
                Navigator.of(context).pop();
              },
              child: Text("continue".tr()))
        ]);
  }

  @override
  void initState() {
    super.initState();
    getSemsters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Semester"),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColorDark,
          foregroundColor: Theme.of(context).primaryColorLight,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                    GradelyPageRoute(builder: (context) => CreateSemester()))
                .then((_) => getSemsters());
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
                    itemCount: _semesterList.length,
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
                                    isCupertino
                                        ? CupertinoIcons.rectangle_on_rectangle
                                        : Icons.copy,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  onTap: () => duplicateSemester(index)),
                            ),
                            IconSlideAction(
                              color: Theme.of(context).primaryColorDark,
                              iconWidget: Icon(
                                isCupertino ? CupertinoIcons.pen : Icons.edit,
                                color: Theme.of(context).primaryColorLight,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  GradelyPageRoute(
                                      builder: (context) => UpdateSemester(
                                          semester: _semesterList[index])),
                                ).then((_) => getSemsters());
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
                                    isCupertino
                                        ? CupertinoIcons.delete
                                        : Icons.delete_outline,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  onTap: () => deleteSemester(index)),
                            ),
                          ],
                          child: Container(
                            decoration: listContainerDecoration(context,
                                index: index, list: _semesterList),
                            child: Column(
                              children: [
                                ContextMenuRegion(
                                  onItemSelected: (item) => {item.onSelected!()},
                                  menuItems: [
                                    MenuItem(
                                      onSelected: () => deleteSemester(index),
                                      title: "delete".tr(),
                                    ),
                                    MenuItem(
                                        onSelected: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateSemester(
                                                        semester: _semesterList[
                                                            index])),
                                          ).then((_) => getSemsters());
                                        },
                                        title: "edit".tr()),
                                    MenuItem(
                                        onSelected: () =>
                                            duplicateSemester(index),
                                        title: "duplicate".tr()),
                                  ],
                                  child: ListTile(
                                    title: Text(
                                      _semesterList[index].name,
                                    ),
                                    trailing: IconButton(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        icon: Icon(Icons.arrow_forward),
                                        onPressed: () async {
                                          await semesterController
                                              .setActiveSemester(
                                                  _semesterList[index].id);
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
}
