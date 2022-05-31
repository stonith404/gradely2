import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/controllers/grade_controller.dart";
import "package:gradely2/components/utils/grades.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/components/widgets/dialogs.dart";
import "package:gradely2/components/widgets/modalsheets.dart";

Future<Widget?> updateGrade(context, {required Grade grade}) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gradeTextController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  nameController.text = grade.name;
  gradeTextController.text = grade.grade == -99 ? "" : grade.grade.toString();
  weightController.text = grade.weight.toString();
  dateController.text = formatDateForClient(grade.date.toString());

  return gradelyModalSheet(
    context: context,
    children: [
      SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          gradelyIconButton(
              onPressed: () async {
                try {
                  await GradeController(context).update(
                      id: grade.id,
                      name: nameController.text,
                      grade: gradeTextController.text,
                      weight: weightController.text,
                      date: dateController.text);
                } catch (_) {
                  isLoadingController.add(false);
                  errorSuccessDialog(
                      context: context,
                      error: true,
                      text: "error_grade_badly_formatted".tr());
                }
                Navigator.of(context).pop();
              },
              icon:
                  Icon(Icons.edit, color: Theme.of(context).primaryColorLight)),
        ],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Text(
          grade.name,
          style: bigTitle,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Divider(
          thickness: 2,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: nameController,
          textAlign: TextAlign.left,
          decoration: inputDec(context, label: "exam_name".tr()),
        ),
      ),
      StatefulBuilder(
        builder: (BuildContext context, setState) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2035),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                              primary: Colors.black,
                              onSurface: Theme.of(context).primaryColorDark),
                          dialogBackgroundColor:
                              Theme.of(context).backgroundColor,
                          textButtonTheme: TextButtonThemeData(
                              style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).primaryColorDark),
                          )),
                        ),
                        child: child!,
                      );
                    });
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    dateController.text = formatDateForClient(picked);
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                    controller: dateController,
                    textAlign: TextAlign.left,
                    decoration: inputDec(context, label: "date".tr())),
              ),
            ),
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: gradeTextController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.left,
          decoration: inputDec(context, label: "grade".tr()),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.left,
          decoration: inputDec(context, label: "weight".tr()),
        ),
      ),
    ],
  );
}
