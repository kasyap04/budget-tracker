import 'package:flutter/material.dart';


import '../../utils/common.dart';

class CategoryAmountLabel extends StatelessWidget{
  final String label ;
  final String currencyCode;
  final double amount ;
  final Color color ;
  CategoryAmountLabel({super.key, required this.label, required this.amount, required this.currencyCode, required this.color});

  final CommonUtil util = CommonUtil() ;

  @override
  Widget build(BuildContext context){
    
    return Row(
      children: [
        Text("$label : ", style: TextStyle(fontSize: 12, color: color)),
        Icon(util.currencyIcon(currencyCode), size: 10, color: color,),
        Text(util.formatAmount(amount, currencyCode), style: TextStyle(fontSize: 12, color: color))
      ],
    ) ;
  }
}