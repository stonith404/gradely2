import 'package:flutter/material.dart';
import 'package:gradely/data.dart';
import 'package:gradely/main.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'semesterDetail.dart';
import 'LessonsDetail.dart';
import 'main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quiver/iterables.dart';

List<_StatsData> list;

class _StatsData {
  _StatsData(this.date, this.grades);
  final String date;
  final double grades;
}

getData() {
  list = [];
  for (var e in zip([averageList, dateList])) {
    list.add(
      _StatsData(e[1], e[0]),
    );
  }
}

Future StatisticsScreen(BuildContext context) {
  getData();

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
                          backgroundColor: defaultColor,
                          child: IconButton(
                              color: Colors.white,
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
                          LineSeries<_StatsData, String>(
                              dataSource: list,
                              xValueMapper: (_StatsData stats, _) => stats.date
                                  .substring(
                                      0, stats.date.toString().length - 3),
                              color: defaultColor,
                              yValueMapper: (_StatsData stats, _) =>
                                  stats.grades)
                        ])),
                    Text("stats1".tr())
                  ],
                )),
          ));
    }),
  );
}
