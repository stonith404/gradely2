import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/shared/WIDGETS.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _AppInfo {
  String leading;
  String ending;

  _AppInfo(this.leading, this.ending);
}

List<_AppInfo> _appInfoList = [];

class AppInfo extends StatefulWidget {
  @override
  _AppInfoState createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  deviceInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
    _appInfoList = [
      _AppInfo("appName", appName),
      _AppInfo("version", version),
      _AppInfo("build", buildNumber),
      _AppInfo(
        "Server Location",
        "Bern Switzerland",
      ),
      _AppInfo("App Language", Localizations.localeOf(context).toString())
    ];
  }

  @override
  void initState() {
    super.initState();
    deviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        backgroundColor: defaultBGColor,
        elevation: 0,
        title: Text("customize".tr(), style: appBarTextTheme),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: whiteBoxDec(),
                child: ListView.builder(
                  primary: false,
                  itemCount: _appInfoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Text(
                            _appInfoList[index].leading,
                            style: TextStyle(fontSize: 17),
                          ),
                          trailing: Text(_appInfoList[index].ending,
                              style: TextStyle(
                                  fontSize: 17, color: Colors.grey[700])),
                        ),
                        listDivider()
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
