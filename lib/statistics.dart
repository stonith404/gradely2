import 'package:flutter/material.dart';
import 'package:gradely/data.dart';
import 'package:gradely/main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'semesterDetail.dart';
import 'LessonsDetail.dart';
import 'main.dart';

import 'package:quiver/iterables.dart';

List<SalesData> list;

class Charts extends StatefulWidget {
  @override
  _ChartsState createState() => _ChartsState();
}

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

class _ChartsState extends State<Charts> {
  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      appBar: AppBar(),
        body: Column(children: [
         Container(
                child: SfCartesianChart(

                    primaryXAxis: CategoryAxis(),
                    series: <ChartSeries>[
          LineSeries<SalesData, String>(
              dataSource: list,

              xValueMapper: (SalesData sales, _) => sales.year, color: defaultColor,
              yValueMapper: (SalesData sales, _) => sales.sales)
        ]))],));
  }
}
