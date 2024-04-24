import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryGraph extends StatelessWidget{
  final double totalSpend ;
  final double totalAmount ;
  final List<Map> category ;
  const CategoryGraph({super.key, required this.totalSpend, required this.category, required this.totalAmount});



  @override
  Widget build(BuildContext context){
    List<CategoryData> chartData = [] ;

    for (var element in category) {
      double perc = (element['amount_spend'] / element['total_amount']) * 100 ;
      chartData.add(CategoryData(
        element['category_name'],
        perc.toInt().toDouble()
      )) ;
    }


    return Visibility(
      visible: totalSpend > 0,
      child: SizedBox(
        height: 250,
        child: SfCircularChart(
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.bottom,
            isResponsive: true
          ),
          
          series: <CircularSeries>[
            PieSeries<CategoryData, String>(
              dataSource: chartData,
              xValueMapper: (CategoryData data, _) => data.name,
              yValueMapper: (CategoryData data, _) => data.perc,
              dataLabelMapper: (CategoryData data, _) => "${data.perc}%",
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                connectorLineSettings: ConnectorLineSettings(
                  type: ConnectorType.curve
                ),
                overflowMode: OverflowMode.shift,
                showZeroValue: false,
                labelPosition: ChartDataLabelPosition.outside
              ),
              
            )
          ],
        ),
      ),
    );
  }
}


class CategoryData{
  CategoryData(this.name, this.perc) ;
  final String name ;
  final double perc ;
}