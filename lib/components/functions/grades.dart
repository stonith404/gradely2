import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

double getPluspoints(num value) {
  double plusPoints;

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
  } else if (value.isNaN) {
    plusPoints = 0;
  }
  return plusPoints;
}

String formatDateForDB(date) {
  try {
    var _formatted = DateTime.parse(date.toString());
    return "${_formatted.year}.${(() {
      if ((_formatted.month).toString().length == 1) {
        return NumberFormat("00").format(_formatted.month);
      } else {
        return _formatted.month;
      }
    }())}.${(() {
      if ((_formatted.day).toString().length == 1) {
        return NumberFormat("00").format(_formatted.day);
      } else {
        return _formatted.day;
      }
    }())}";
  } catch (_) {
    return "${date.substring(6, 10)}.${date.substring(3, 5)}.${date.substring(0, 2)}";
  }
}

String formatDateForClient(date) {
  if (date == "") {
    return "-";
  } else {
    try {
      var _formatted = DateTime.parse(date.toString());
      return "${(() {
        if ((_formatted.day).toString().length == 1) {
          return NumberFormat("00").format(_formatted.day);
        } else {
          return _formatted.day;
        }
      }())}.${(() {
        if ((_formatted.month).toString().length == 1) {
          return NumberFormat("00").format(_formatted.month);
        } else {
          return _formatted.month;
        }
      }())}.${_formatted.year}";
    } catch (_) {
      return "${date.substring(8, 10)}.${date.substring(5, 7)}.${date.substring(0, 4)}";
    }
  }
}

String roundGrade(double value, double x) {
  if (x == 0.1) {
    return value.toStringAsFixed(1);
  } else if (x == 1) {
    return value.roundToDouble().toString();
  } else if (x == 0.5) {
    return ((value * 2).round() / 2).toString();
  } else {
    return value.toStringAsFixed(2);
  }
}


FilteringTextInputFormatter emojiRegex() {
  return FilteringTextInputFormatter.deny(RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'));
}
