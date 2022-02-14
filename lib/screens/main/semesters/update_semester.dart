import "package:easy_localization/easy_localization.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/controllers/semester_controller.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/main.dart";

class UpdateSemester extends StatelessWidget {
  final Semester semester;
  final SemesterController semesterController =
      SemesterController(navigatorKey.currentContext);
  final TextEditingController _nameController = TextEditingController();
  UpdateSemester({Key? key, required this.semester}) : super(key: key) {
    _nameController.text = semester.name;
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = semester.name;
    double roundTo = semester.round;
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
                  controller: _nameController,
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
                      thumbColor: Theme.of(context).primaryColorLight,
                      groupValue: roundTo,
                      children: {
                        0.1: Text("0.1"),
                        0.5: Text("0.5"),
                        0.01: Text("0.01")
                      },
                      onValueChanged: (dynamic n) => {setState(() => roundTo = n)}),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              gradelyButton(
                text: "save".tr(),
                onPressed: () async {
                  isLoadingController.add(true);
                  await semesterController.update(
                      id: semester.id,
                      name: _nameController.text,
                      round: roundTo);
                  Navigator.of(context).pop();
                  isLoadingController.add(false);
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
