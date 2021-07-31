import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
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
  String _serverUp;
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  deviceInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (await internetConnection()) {
      _serverUp = "connected";
    } else {
      _serverUp = "not connected";
    }

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
    _appInfoList = [
      _AppInfo("app_name".tr(), appName),
      _AppInfo("version".tr(), version),
      _AppInfo("build".tr(), buildNumber),
      _AppInfo(
        "server_location".tr(),
        "Bern, Switzerland",
      ),
      _AppInfo("app_language".tr(), Localizations.localeOf(context).toString()),
      _AppInfo(
        "server_connection".tr(),
        _serverUp.toString(),
      ),
      _AppInfo("licenses".tr(), "licenses")
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
        title: Text("app_info".tr(), style: appBarTextTheme),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Flexible(
              child: Container(
                decoration: whiteBoxDec(),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _appInfoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        listDivider(),
                        ListTile(
                          leading: Text(
                            _appInfoList[index].leading,
                          ),
                          trailing: _appInfoList[index].ending == "licenses"
                              ? IconButton(
                                  onPressed: () {
                                    showLicensePage(
                                        context: context,
                                        applicationIcon: SvgPicture.asset(
                                            "assets/images/logo.svg",
                                            color: primaryColor,
                                            height: 30));
                                  },
                                  icon: Icon(Icons.arrow_forward_ios, size: 20))
                              : Text(_appInfoList[index].ending,
                                  style: TextStyle(
                                      color: _appInfoList[index].leading ==
                                              "server_connection".tr()
                                          ? (_serverUp == "connected"
                                              ? Colors.green
                                              : Colors.red)
                                          : Colors.grey[700])),
                        ),
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