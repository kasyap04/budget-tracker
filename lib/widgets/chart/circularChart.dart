import 'package:flutter/material.dart';


// ignore: must_be_immutable
class CircularChart extends StatelessWidget{
  final double value ;
  final String perc ;
  final Color color;
  late Color? backgroundColor ;
  late Color? textColor ;
  CircularChart({super.key, required this.value, required this.perc, required this.color, this.backgroundColor, this.textColor});

  @override
  Widget build(BuildContext context){
    return Stack(
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: 10,
            value: value,
            backgroundColor: backgroundColor ?? const Color.fromARGB(255, 214, 214, 214),
          )
        ),
        Positioned(
          top: 17,
          child: SizedBox(
            width: 50,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "$perc%",
                style: TextStyle(
                  color: textColor ?? Colors.red,
                    fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          )
        )
      ],
    );
  }
}

// class CircularChart extends StatelessWidget{
//   final Map<String, double> dataMap = {
//     "flutter": 60
//   } ;

//   CircularChart({super.key});

//   @override
//   Widget build(BuildContext context){
//     return PieChart(
//           dataMap: dataMap,
//           chartType: ChartType.ring,
//           baseChartColor: Colors.red,
//           gradientList: const [
//             [
//               Colors.blue,
//               Colors.green
//             ]
//           ],
//           legendOptions: const LegendOptions(
//             showLegends: false
//           ),
//           chartValuesOptions: const ChartValuesOptions(
//             showChartValuesInPercentage: true,
//           ),
//           totalValue: 100,
//         ) ;
//   }
  
// }