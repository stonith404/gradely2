import "dart:convert";
import "package:universal_io/io.dart";
import "package:appwrite/appwrite.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/widgets/dialogs.dart";
import "package:gradely2/components/variables.dart";
import "package:in_app_review/in_app_review.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:easy_localization/easy_localization.dart";
import "package:http/http.dart" as http;
import "package:gradely2/env.dart" as env;

//checks if client is connected to the server. The function stores the value for 10 seconds
// to reduce requests.
Future<bool> internetConnection() async {
  var cache = jsonDecode(prefs.getString("internetConnection_cache") ??
      '{"time": 0, "state" : false}');
  var timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  saveCache(state) {
    prefs.setString(
        "internetConnection_cache", '{"time": $timestamp, "state" : $state}');
  }

  if (kIsWeb) {
    return true;
  } else if (timestamp - cache["time"] <= 10) {
    return cache["state"];
  } else {
    try {
      await http
          .get(Uri.parse(env.APPWRITE_ENDPOINT))
          .timeout(Duration(milliseconds: 3000));
      saveCache(true);
      return true;
    } catch (e) {
      print(e);
      saveCache(false);
      return false;
    }
  }
}

Future<bool> isMaintenance() async {
  try {
    var request = await http
        .get(Uri.parse(env.STATIC_API_ENDPOINT))
        .timeout(const Duration(seconds: 3));
    return jsonDecode(request.body)["maintenance"];
  } catch (_) {
    return false;
  }
}

//if there is no connection, show a dialog
void noNetworkDialog(context) async {
  if (!await (internetConnection())) {
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

// ignore: non_constant_identifier_names
PageRoute GradelyPageRoute({Widget Function(BuildContext)? builder}) {
  if (Platform.isIOS) {
    return MaterialWithModalsPageRoute(builder: builder!);
  } else {
    return MaterialPageRoute(builder: builder!);
  }
}

// ask for an in app rating. This gets executed when the account is older then 30 days.

askForInAppRating(context) async {
  int today = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  bool isLastAskedOlderThen14Days;
  bool neverAskAgain = prefs.getBool("never_ask_again_review") ?? false;

  try {
    isLastAskedOlderThen14Days =
        (today - prefs.getInt("timestamp_asked_for_review")! > 1296000);
  } catch (_) {
    isLastAskedOlderThen14Days = true;
  }

  bool isAccountOlderThen30Days = (today - user.registration) > 2592000;
  final InAppReview inAppReview = InAppReview.instance;

  if (!neverAskAgain &&
      isAccountOlderThen30Days &&
      isLastAskedOlderThen14Days &&
      (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) &&
      await inAppReview.isAvailable()) {
    gradelyDialog(
      context: context,
      title: "rate".tr(),
      text: "rate_gradely2_popup".tr(),
      actions: [
        TextButton(
            onPressed: () {
              prefs.setBool("never_ask_again_review", true);
              Navigator.of(context).pop();
            },
            child: Text("never".tr())),
        TextButton(
            onPressed: () {
              prefs.setInt("timestamp_asked_for_review", today);
              Navigator.of(context).pop();
            },
            child: Text("maybe_later".tr())),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              inAppReview.requestReview();
              prefs.setInt("timestamp_asked_for_review", today);
              prefs.setBool("never_ask_again_review", true);
            },
            child: Text("sure".tr()))
      ],
    );
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
              "min_${() {
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
              }() as String}_version")
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
