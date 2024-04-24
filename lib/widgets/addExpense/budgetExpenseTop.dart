import 'package:flutter/material.dart';

import '../../utils/constant.dart';
import '../../utils/common.dart';


class BudgetExpenseTop extends StatelessWidget{
  final String categoryName ;
  final double totalAmount ;
  final double spendAmount ;
  final String currencyCode ;
  BudgetExpenseTop({super.key, required this.categoryName, required this.totalAmount, required this.spendAmount, required this.currencyCode});

  final CommonUtil commonUtil = CommonUtil() ;

  @override
  Widget build(BuildContext context){
    double balanceAmount  = totalAmount - spendAmount ;
    bool exeedStatus      = false ;

    if(balanceAmount < 0){
      exeedStatus = true ;
      balanceAmount = spendAmount - totalAmount ;
    }


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        children: [
          Text(categoryName, style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const Padding(padding: EdgeInsets.only(bottom: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              commonUtil.amountAndLabel(label: "Spend", amount: spendAmount, code: currencyCode, color: primaryColor, lableColor: primaryColor.withOpacity(0.8), size: 15),
              commonUtil.amountAndLabel(label: exeedStatus ? "Exceeded" : "Limit left", amount: balanceAmount, code: currencyCode, color: exeedStatus ? Colors.red : primaryColor, lableColor: exeedStatus ? Colors.red : primaryColor.withOpacity(0.8), size: 15),
              commonUtil.amountAndLabel(label: "Total amount", amount: totalAmount, code: currencyCode, color: primaryColor, lableColor: primaryColor.withOpacity(0.8), size: 15)
            ],
          )
        ],
      ),
    ) ;
  }
}