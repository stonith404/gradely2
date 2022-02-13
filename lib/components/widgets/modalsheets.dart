import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";

Future<Widget> gradelyModalSheet(
    {@required BuildContext context, @required List<Widget> children}) {
  return showCupertinoModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expand: true,
      context: context,
      builder: (context) => SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            controller: ModalScrollController.of(context),
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ));
}

Widget gradelyModalSheetHeader(BuildContext context,
    {String title,
    Icon icon = const Icon(CupertinoIcons.xmark),
    Widget customHeader}) {
  return Column(
    children: [
      SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          gradelyIconButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              icon: icon),
        ],
      ),
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: (() {
            if (title == null) {
              return customHeader;
            } else {
              return Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              );
            }
          }())),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Divider(
          thickness: 2,
        ),
      ),
    ],
  );
}
