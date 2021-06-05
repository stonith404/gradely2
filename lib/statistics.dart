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

List<SalesData> list;

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}

getData() {
  list = [];
  for (var e in zip([averageList, dateList])) {
    list.add(
      SalesData(e[1], e[0]),
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
                          LineSeries<SalesData, String>(
                              dataSource: list,
                              xValueMapper: (SalesData sales, _) => sales.year
                                  .substring(
                                      0, sales.year.toString().length - 3),
                              color: defaultColor,
                              yValueMapper: (SalesData sales, _) => sales.sales)
                        ])),
                        Text("stats1".tr())
                  ],
                )),
          ));
    }),
  );
}
