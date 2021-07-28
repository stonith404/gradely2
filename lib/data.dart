import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

final String cacheField = 'updatedAt';


num plusPoints = 0;


num plusPointsallAverageList = 0;
Timer timer;

String releaseNotes = "";
bool internetConnected = true;

getPluspoints(num value) {
  if (value >= 5.75) {
    plusPoints = 2;
  } else if (value >= 5.25) {
    plusPoints = 1.5;
  } else if (value >= 4.75) {
    plusPoints = 1;
  } else if (value >= 4.25) {
    plusPoints = 0.5;
  } else if (value >= 3.75) {
    plusPoints = 0;
  } else if (value >= 3.25) {
    plusPoints = -1;
  } else if (value >= 2.75) {
    plusPoints = -2;
  } else if (value >= 2.25) {
    plusPoints = -3;
  } else if (value >= 1.75) {
    plusPoints = -4;
  } else if (value >= 1.25) {
    plusPoints = -5;
  } else if (value >= 1) {
    plusPoints = -6;
  } else if (value == -99) {
    plusPoints = 0;
  }else if (value.isNaN) {
    plusPoints = 0;
  }
  return plusPoints;
}

getPluspointsallAverageList(num value) {
  if (value >= 5.75) {
    plusPointsallAverageList = 2;
  } else if (value >= 5.25) {
    plusPointsallAverageList = 1.5;
  } else if (value >= 4.75) {
    plusPointsallAverageList = 1;
  } else if (value >= 4.25) {
    plusPointsallAverageList = 0.5;
  } else if (value >= 3.75) {
    plusPointsallAverageList = 0;
  } else if (value >= 3.25) {
    plusPointsallAverageList = -1;
  } else if (value >= 2.75) {
    plusPointsallAverageList = -2;
  } else if (value >= 2.25) {
    plusPointsallAverageList = -3;
  } else if (value >= 1.75) {
    plusPointsallAverageList = -4;
  } else if (value >= 1.25) {
    plusPointsallAverageList = -5;
  } else if (value >= 1) {
    plusPointsallAverageList = -6;
  } else if (value.isNaN) {
    plusPoints = 0;
  }
}
var testDetails;

formatDate(picked) {
  var _formatted = DateTime.parse(picked.toString());
  return "${_formatted.year}.${_formatted.month}.${_formatted.day}";
}


void launchURL(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';






