import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/controllers/subject_controller.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:gradely2/components/widgets/decorations.dart";

class UpdateSubject extends StatelessWidget {
  final Lesson lesson;
  final TextEditingController _nameController = TextEditingController();

  UpdateSubject({Key key, this.lesson}) : super(key: key) {
    _nameController.text = lesson.name;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
        appBar: AppBar(
          title: Text("edit".tr()),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              Spacer(flex: 2),
              TextField(
                  controller: _nameController,
                  textAlign: TextAlign.left,
                  decoration: inputDec(context, label: "lesson_name".tr())),
              SizedBox(
                height: 40,
              ),
              gradelyButton(
                text: "save".tr(),
                onPressed: () async {
                  SubjectController(context)
                      .update(id: lesson.id, name: _nameController.text);
                  Navigator.of(context).pop();
                },
              ),
              Spacer(flex: 5),
            ],
          ),
        ),
      );
    });
  }
}
