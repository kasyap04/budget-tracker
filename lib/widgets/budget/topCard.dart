import 'package:flutter/material.dart';

import '../../utils/constant.dart';
import '../../utils/common.dart';

class BudgetTopCard extends StatelessWidget{
  final double spend ;
  final double totalAmount ;
  final String startDate ;
  final String endDate ;
  final String currencyCode ;
  final bool isLoading ;
  BudgetTopCard({super.key, required this.spend, required this.totalAmount, required this.startDate, required this.endDate, required this.currencyCode, required this.isLoading});

  final CommonUtil commonUtil = CommonUtil() ;

  final Color textColor = const Color.fromARGB(255, 203, 203, 203);

  @override
  Widget build(BuildContext context){

    DateTime dateStart  = commonUtil.strDateToDateTime(startDate) ;
    DateTime dateEnd    = commonUtil.strDateToDateTime(endDate) ;

    double balanceAmount = totalAmount - spend ;
    String balanceStr = "Balance" ;
    Color balanceColor = textColor ;
    if(balanceAmount < 0){
      balanceStr = "Exceeded" ;
      balanceAmount = spend - totalAmount ;
      balanceColor = Colors.red ;
    }

    Size size = MediaQuery.of(context).size ;
    return Container(
      width: size.width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            commonUtil.displayAmount(
              amount: spend,
              code: currencyCode,
              color: Colors.white,
              size: 40,
              bold: false
            ),
            const Text("Total spend", style: TextStyle(color: Color.fromARGB(255, 203, 203, 203), fontSize: 12),),
            space(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                displayDate(
                  date: commonUtil.dateTimePrettyFormat(dateStart),
                  label: "From"
                ),
                displayDate(
                  date: commonUtil.dateTimePrettyFormat(dateEnd),
                  label: "To"
                ),
              ],
            ),
            space(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                value: balanceAmount == 0 ? 1 : spend/balanceAmount,
                backgroundColor: Colors.grey.withOpacity(0.3),
                color: Colors.grey,
                minHeight: 5,
              )
            ),

            space(25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                displayAmount(label: balanceStr, icon: commonUtil.currencyIcon(currencyCode), amount: commonUtil.formatAmount(balanceAmount, currencyCode), color: balanceColor),
                displayAmount(label: "Budget", icon: commonUtil.currencyIcon(currencyCode), amount: commonUtil.formatAmount(totalAmount, currencyCode), color: balanceColor)
              ],
            ),
        ],
      ),
    ) ;
  }

  Widget space(double space) => Padding(padding: EdgeInsets.only(bottom: space)) ;
  
  Widget displayDate({required String label, required String date}) => Row(
    children: [
      Text("$label  ", style: TextStyle(color: textColor, fontSize: 13),),
      Icon(Icons.calendar_month, color: textColor, size: 12,),
      Text(" $date", style: TextStyle(color: textColor, fontSize: 13),)
    ],
  ) ;

  Widget displayAmount({required String label, required IconData icon, required String amount, required Color color}) => Row(
    children: [
      Text(label, style: TextStyle(color: color, fontSize: 13)),
      Icon(icon, color: color, size: 12,),
      Text(amount, style: TextStyle(color: color, fontSize: 13),)
    ],
  ) ;

}