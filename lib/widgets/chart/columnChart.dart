import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'columnChartWidgets/dropDown.dart';
import 'columnChartWidgets/switchTime.dart';
import '../../utils/constant.dart';
import '../../utils/common.dart';
import '../../controller/chartController.dart';

class ColumnChart extends StatefulWidget{
  final String currencyCode ;
  final bool isLoading ;
  final int expenseType ;
  const ColumnChart({super.key, required this.currencyCode, required this.isLoading, required this.expenseType});

  @override
  State<ColumnChart> createState() => ColumnChartState() ;
}

class ColumnChartState extends State<ColumnChart>{
  final CommonUtil commonUtil = CommonUtil() ;
  final ChartController chartController = ChartController(commonUtil: CommonUtil()) ;

  DateTime date = DateTime.now() ;
  String timePeriod = 'monthly' ;
  String displayDate = "" ;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    Size size = MediaQuery.of(context).size ;

    if(widget.isLoading){
      return Text("Loading graph") ;
    }

    return FutureBuilder(
      future: chartController.changeDropDown(timePeriod, date, widget.expenseType),
      builder: (context, snaphot) {
        
        if(snaphot.hasData){

			Map<String, dynamic>? snapData = snaphot.data ;
			double maxAmount 	= snapData?['max'] ;
			double totalExpense = snapData?['sum'] ;
			displayDate			= snapData?['displayDate'] ;
			List<Map<String, dynamic>> expenseChart = snapData?['chart'] ;


			List<ChartData> data = [] ;
			for (var element in expenseChart) {
				data.add(
					ChartData(element['date'], element['amount'])
				) ;
			}

			return Column(
				crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Row(
					children: [
						Icon(commonUtil.currencyIcon(widget.currencyCode), size: 30, color: primaryColor),
						Text(commonUtil.formatAmount(totalExpense, widget.currencyCode), style:  TextStyle(fontSize: 30, color: primaryColor))
					],
				),
				const Text("Total spend", style: TextStyle(color: Colors.grey, fontSize: 12)),
				const Padding(padding: EdgeInsets.only(bottom: 20)),
				Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					SwitchTime(
            width: (size.width / 2) + 15,
            height: 40,
            value: displayDate,
            backward: () => changePeriod(forward: false),
            forward: () => changePeriod(forward: true),
					),
					DropDown(
            defaultValue: timePeriod,
            width: (size.width / 2) - 45,
            height: 40,
            valueChanged: (value) => setState(() => timePeriod = value)
					),
				],
				),
				SizedBox(
				height: 200,
				child: SfCartesianChart(
					primaryXAxis: CategoryAxis(),
					primaryYAxis: NumericAxis(isVisible: false, maximum: maxAmount),
					tooltipBehavior: TooltipBehavior(enable: true),
					enableAxisAnimation: true,
					enableMultiSelection: false,
					series: <ChartSeries<ChartData, String>>[
						ColumnSeries(
						dataSource: data, 
						xValueMapper: (ChartData data, _) => data.value, 
						yValueMapper: (ChartData data, _) => data.amount,
						name: 'Expense',
						color: primaryColor.withOpacity(0.8),
						borderRadius: BorderRadius.circular(8),
					
						)
					],
				),
				),
			],
			);
        } else {
			return const Text("Loading chart") ;
		}

      }
    );
  }


	void changePeriod({required bool forward}){
		final changableDate = chartController.changeDatePeriod(timePeriod, date, forward) ;
		setState(() {
			date = changableDate.$1 ;
			displayDate = changableDate.$2 ;
		});
	}

}


class ChartData {
  final String value ;
  final double amount ;
  ChartData(this.value, this.amount) ;
}