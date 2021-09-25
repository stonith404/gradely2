import 'package:flutter/material.dart';
import 'package:gradely2/shared/CLASSES.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:easy_localization/easy_localization.dart';

List<Grade> statsList = [];

Future statisticsScreen(BuildContext context) {
  statsList = [];
  gradeList.sort((a, b) => a.date.compareTo(b.date));
  for (var item in gradeList) {
    statsList.add(Grade("", "", item.grade, item.weight, item.date));
  }
  return showCupertinoModalBottomSheet(
    expand: true,
    context: context,
    builder: (context) =>
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Material(
            color: defaultBGColor,
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("statistics".tr(), style: TextStyle(fontSize: 25)),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: primaryColor,
                          child: IconButton(
                              color: frontColor(),
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
                    Container(
                        child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            series: <ChartSeries>[
                          LineSeries<Grade, String>(
                              dataSource: statsList,
                              xValueMapper: (Grade stats, _) => stats.date
                                  .substring(
                                      0, stats.date.toString().length - 3),
                              color: primaryColor,
                              yValueMapper: (Grade stats, _) => stats.grade)
                        ])),
                    Text("stats_description".tr())
                  ],
                )),
          ));
    }),
  );
}
