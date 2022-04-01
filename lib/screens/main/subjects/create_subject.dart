import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/controllers/subject_controller.dart";
import "package:gradely2/components/variables.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:gradely2/components/widgets/decorations.dart";

class CreateSubject extends StatelessWidget {
  CreateSubject({Key? key}) : super(key: key);
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add_subject".tr()),
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
                decoration: inputDec(context, label: "subject_name".tr())),
            SizedBox(
              height: 40,
            ),
            gradelyButton(
              text: "add".tr(),
              onPressed: () async {
                isLoadingController.add(true);
                await SubjectController(context)
                    .create(name: _nameController.text);
                Navigator.of(context).pop();
              },
            ),
            Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}
