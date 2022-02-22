import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/variables.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";

Future dreamGradeCalculator(BuildContext context,
    {required double sumWeight, required double sumGrade}) {
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  _gradeController.text = "";
  _weightController.text = "1";
  num dreamgradeResult = 0;
  double? dreamgrade = 0;
  double? dreamgradeWeight = 1;

  return showCupertinoModalBottomSheet(
    expand: true,
    context: context,
    builder: (context) =>
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      getDreamGrade() {
        try {
          setState(() {
            dreamgradeResult =
                ((dreamgrade! * (sumWeight + dreamgradeWeight!) - sumGrade) /
                    dreamgradeWeight!);
          });
        } catch (e) {
          setState(() {
            dreamgradeResult = 0;
          });
        }
      }

      return SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: FittedBox(
                              child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("dream_grade_calulator".tr(), style: title),
                      ))),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Theme.of(context).primaryColorDark,
                        child: IconButton(
                            color: Theme.of(context).primaryColorLight,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _gradeController,
                      onChanged: (String value) async {
                        dreamgrade = double.tryParse(
                            _gradeController.text.replaceAll(",", "."));
                        getDreamGrade();
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.left,
                      decoration: inputDec(context, label: "dream_grade".tr()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _weightController,
                      onChanged: (String value) async {
                        dreamgradeWeight = double.tryParse(
                            _weightController.text.replaceAll(",", "."));
                        getDreamGrade();
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.left,
                      decoration:
                          inputDec(context, label: "dream _grade_weight".tr()),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                      children: [
                        TextSpan(text: "dream_grade_result_text".tr() + "  "),
                        TextSpan(
                            text: (() {
                              if (dreamgradeResult.isInfinite) {
                                return "-";
                              } else {
                                return dreamgradeResult.toStringAsFixed(2);
                              }
                            })(),
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ));
    }),
  );
}
