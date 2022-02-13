import "dart:convert";
import "dart:io";
import "package:appwrite/appwrite.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/widgets/dialogs.dart";
import "package:gradely2/components/variables.dart";
import "package:in_app_review/in_app_review.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:url_launcher/url_launcher.dart";
import "package:easy_localization/easy_localization.dart";
import "package:http/http.dart" as http;

//checks if client is connected to the server. The function stores the value for 5 seconds
// to reduce requests.
Future internetConnection({BuildContext context}) async {
  var _cache = jsonDecode(prefs.getString("internetConnection_cache") ??
      '{"time": 0, "state" : false}');
  var timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  saveCache(state) {
    prefs.setString(
        "internetConnection_cache", '{"time": $timestamp, "state" : $state}');
  }

  if (kIsWeb) {
    return true;
  } else if (timestamp - _cache["time"] <= 5) {
    return _cache["state"];
  } else {
    try {
      await account.get().timeout(Duration(milliseconds: 3000));
      saveCache(true);
      return true;
    } catch (e) {
      if (e.code != null) {
        saveCache(true);
        return true;
      } else {
        saveCache(false);
        return false;
      }
    }
  }
}

Future<bool> isMaintenance() async {
  try {
    var request = await http
        .get(Uri.parse("https://gradelyapp.com/static-api"))
        .timeout(const Duration(seconds: 2));
    return jsonDecode(request.body)["maintenance"];
  } catch (_) {
    return false;
  }
}

//if there is no connection, show a dialog
void noNetworkDialog(context) async {
  if (!await internetConnection()) {
    errorSuccessDialog(
        context: context,
        error: true,
        title: "network_needed_title".tr(),
        text: "network_needed_text".tr());
  }
}

//reads data from the cache

Future sharedPrefs() async {
  prefs = await SharedPreferences.getInstance();
}

//launch url with the package "url launcher"

void launchURL(_url) async => await launch(_url);

//clears all variables when user sign out
void clearVariables() {
  prefs.clear();
}

// ignore: non_constant_identifier_names
PageRoute GradelyPageRoute({Widget Function(BuildContext) builder}) {
  if (Platform.isIOS) {
    return MaterialWithModalsPageRoute(builder: builder);
  } else {
    return MaterialPageRoute(builder: builder);
  }
}

// ask for an in app rating. This gets executed when the account is older then 30 days.

askForInAppRating() async {
  int today = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  bool isLastAskedOlderThen14Days;

  try {
    isLastAskedOlderThen14Days =
        (today - prefs.getInt("timestamp_asked_for_review") > 1296000);
  } catch (_) {
    isLastAskedOlderThen14Days = true;
  }

  bool isAccountOlderThen30Days = (today - user.registration) > 2592000;
  final InAppReview inAppReview = InAppReview.instance;

  if (isAccountOlderThen30Days &&
      isLastAskedOlderThen14Days &&
      (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) &&
      await inAppReview.isAvailable()) {
    inAppReview.requestReview();
    prefs.setInt("timestamp_asked_for_review", today);
  }
}

Future minAppVersion() async {
  try {
    if (kIsWeb) {
      return {"isUpToDate": true};
    }
    String currentVersion = (await PackageInfo.fromPlatform()).version;
    String minAppVersion = (await api.listDocuments(
        collection: "61d43a3784b50",
        name: "minAppVersion",
        queries: [
          Query.equal(
              "key",
              "min_" +
                  (() {
                    if (Platform.isIOS) {
                      return "ios";
                    } else if (Platform.isAndroid) {
                      return "android";
                    } else if (Platform.isMacOS) {
                      return "macos";
                    } else if (Platform.isWindows) {
                      return "windows";
                    } else {
                      return {"isUpToDate": true};
                    }
                  }()) +
                  "_version")
        ]))[0]["value"];
    return {
      "isUpToDate": int.parse(currentVersion.replaceAll(".", "")) >=
          int.parse(minAppVersion.replaceAll(".", "")),
      "currentVersion": currentVersion,
      "minAppVersion": minAppVersion
    };
  } catch (_) {
    return {"isUpToDate": true};
  }
}
