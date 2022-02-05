import 'package:flutter/material.dart';
import 'package:gradely2/components/models.dart';
import 'package:gradely2/components/variables.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:easy_localization/easy_localization.dart';

List<Grade> statsList = [];

Future statisticsScreen(BuildContext context) {
  statsList = [];
  gradeList.sort((a, b) => a.date.compareTo(b.date));
  for (var item in gradeList) {
    statsList.add(Grade('', '', item.grade, item.weight, item.date));
  }
  return showCupertinoModalBottomSheet(
    expand: true,
    context: context,
    builder: (context) =>
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('statistics'.tr(), style: title),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Theme.of(context).primaryColorDark,
                          child: IconButton(
                              color: Theme.of(context).primaryColorLight,
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
                    SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <ChartSeries>[
                      LineSeries<Grade, String>(
                          dataSource: statsList,
                          xValueMapper: (Grade stats, _) => stats.date
                              .substring(
                                  0, stats.date.toString().length - 3),
                          color: Theme.of(context).primaryColorDark,
                          yValueMapper: (Grade stats, _) => stats.grade)
                    ]),
                    Text('stats_description'.tr())
                  ],
                )),
          ));
    }),
  );
}
