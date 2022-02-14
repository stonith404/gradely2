import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/utils/app.dart";
import "package:gradely2/components/utils/user.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:gradely2/components/variables.dart";
import "package:easy_localization/easy_localization.dart";
import "package:package_info_plus/package_info_plus.dart";

Future settingsScreen(BuildContext context, {PackageInfo packageInfo}) {
  String gradesResult = user.gradeType;
  return showCupertinoModalBottomSheet(
    shadow: BoxShadow(
      color: Colors.grey.withOpacity(0.3),
      spreadRadius: 5,
      blurRadius: 7,
      offset: Offset(0, 3), // changes position of shadow
    ),
    context: context,
    builder: (context) => StatefulBuilder(builder:
        (BuildContext context, StateSetter setState /*You can rename this!*/) {
      return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .backgroundColor
                                  .withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          )),
                      child: IconButton(
                          iconSize: 15,
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () async {
                            await getUserInfo();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_forward_ios_outlined)),
                    ),
                  ],
                ),
                Text("options".tr(), style: title),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            settingsListTile(
                                context: context,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "settings/userInfo");
                                },
                                items: [
                                  Icon(
                                      isCupertino
                                          ? CupertinoIcons.person
                                          : Icons.person,
                                      size: 15,
                                      color:
                                          Theme.of(context).primaryColorDark),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                      user.name == "" ? user.email : user.name),
                                  Spacer(
                                    flex: 1,
                                  ),
                                ]),
                            settingsListTile(
                              arrow: false,
                              items: [
                                Icon(
                                    isCupertino
                                        ? CupertinoIcons.plus_slash_minus
                                        : Icons.calculate_outlined,
                                    size: 15,
                                    color: Theme.of(context).primaryColorDark),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("grade_result".tr()),
                                Spacer(
                                  flex: 1,
                                ),
                                DropdownButton<String>(
                                  dropdownColor:
                                      Theme.of(context).backgroundColor,
                                  hint: Text(
                                    gradesResult.tr(),
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  ),
                                  items: <String>[
                                    "av".tr(),
                                    "pp".tr(),
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    var newValue = "av";
                                    if (value == "Pluspunkte") {
                                      newValue = "pp";
                                    } else if (value == "Pluspoints") {
                                      newValue = "pp";
                                    } else {
                                      newValue = "av";
                                    }
                                    api.updateDocument(context,
                                        documentId: user.dbID,
                                        collectionId: collectionUser,
                                        data: {
                                          "gradeType": newValue,
                                        });
                                    setState(() {
                                      gradesResult = newValue;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        decoration: boxDec(context),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                          decoration: boxDec(context),
                          child: Column(
                            children: [
                              settingsListTile(
                                context: context,
                                items: [
                                  Icon(
                                      isCupertino
                                          ? CupertinoIcons.heart
                                          : Icons.favorite_outline,
                                      size: 15,
                                      color:
                                          Theme.of(context).primaryColorDark),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("support".tr()),
                                ],
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "settings/supportApp");
                                },
                              ),
                              settingsListTile(
                                  items: [
                                    Icon(
                                        isCupertino
                                            ? CupertinoIcons.cloud_download
                                            : Icons.download_outlined,
                                        size: 15,
                                        color:
                                            Theme.of(context).primaryColorDark),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("downloads".tr()),
                                  ],
                                  onTap: () => launchURL(
                                      "https://gradelyapp.com#download")),
                            ],
                          ))
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        "v${packageInfo.version}",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }),
  );
}

ListTile settingsListTile({
  BuildContext context,
  List<Widget> items,
  onTap,
  arrow = true,
}) {
  if (arrow) {
    items.add(
      Spacer(
        flex: 1,
      ),
    );
    items.add(
      Icon(CupertinoIcons.forward),
    );
  }

  return ListTile(title: Row(children: items), onTap: onTap);
}
