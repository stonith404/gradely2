import "dart:convert";
import "package:flutter/material.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/components/variables.dart";
import "package:easy_localization/easy_localization.dart";
import "package:gradely2/components/widgets/toast.dart";

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _contactMessageController =
      TextEditingController();

  sendMail(String message) async {
    var maildata = jsonEncode({"sender": user.email, "message": message});
    Future result = functions.createExecution(
        functionId: "fcn_contact", data: maildata.toString());
    await result.then((response) {
      Navigator.pushNamed(context, "subjects");
      toast.success(context,
          text: "${"contact_success_text".tr()} ${user.email}.",
          title: "sent".tr());
    }).catchError((error) {
      Navigator.pushNamed(context, "subjects");
      toast.error(context, text: "error_contact".tr());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(title: Text("contact_developer".tr())),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              SizedBox(height: 40),
              TextField(
                  controller: _contactMessageController,
                  maxLines: 8,
                  decoration: inputDec(context, label: "your_message".tr())),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  gradelyButton(
                      onPressed: () async {
                        isLoadingController.add(true);
                        if (_contactMessageController.text == "") {
                        } else {
                          await sendMail(_contactMessageController.text);
                        }
                        isLoadingController.add(false);
                      },
                      text: "send".tr()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
