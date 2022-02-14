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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gradeTextController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  _nameController.text = grade.name;
  _gradeTextController.text = grade.grade == -99 ? "" : grade.grade.toString();
  _weightController.text = grade.weight.toString();
  _dateController.text = formatDateForClient(grade.date.toString());

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
                  GradeController(context).update(
                      id: grade.id,
                      name: _nameController.text,
                      grade: _gradeTextController.text,
                      weight: _weightController.text,
                      date: _dateController.text);
                } catch (_) {
                  isLoadingController.add(false);
                  errorSuccessDialog(
                      context: context,
                      error: true,
                      text: "error_grade_badly_formatted".tr());
                }
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
          controller: _nameController,
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
                    _dateController.text = formatDateForClient(picked);
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                    controller: _dateController,
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
          controller: _gradeTextController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.left,
          decoration: inputDec(context, label: "grade".tr()),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.left,
          decoration: inputDec(context, label: "weight".tr()),
        ),
      ),
    ],
  );
}
