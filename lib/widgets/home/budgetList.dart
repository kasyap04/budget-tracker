import 'package:budget_tracker/utils/constant.dart';
import 'package:flutter/material.dart';

import '../chart/circularChart.dart';
import '../../utils/common.dart';
import '../common/deleteButton.dart';
import '../common/editButton.dart';

class BudgetList extends StatelessWidget{
  final double width ;
  final String currencyCode;
  final String budgetName ;
  final int categoryCount ;
  final String fromDate ;
  final String endDate ;
  final double totalAmount ;
  final double spentAmount;
  final int budgetId ;
  final bool isExpaired ;
  final bool showActions ;
  final Map budgetData ;
  final void Function(int budgetId) action ;
  final void Function(int id) deleteBudget ;
  final void Function(Map data) editBudget ;
  BudgetList({super.key, required this.width, required this.currencyCode,  required this.budgetName, required this.categoryCount, required this.fromDate, required this.endDate, required this.totalAmount, required this.spentAmount, required this.budgetId, required this.action, required this.isExpaired, required this.showActions, required this.deleteBudget, required this.editBudget, required this.budgetData});

  final CommonUtil commonUtil = CommonUtil() ;

  @override
  Widget build(BuildContext context){

    double balanceAmount = totalAmount - spentAmount ;
    String amountStr1   = "left", amountStr2 = "out of" ;
    Color amountColor   = primaryColor ;
    bool exceedStatus   = false ;

    if(balanceAmount < 0){
      amountStr1 = "exceeded" ;
      amountStr2 = "from" ;
      balanceAmount = spentAmount - totalAmount ;
      amountColor = Colors.red ;
      exceedStatus = true ;
    } 

    double perc = (spentAmount * 100) / totalAmount ;

    List<Widget> expiredLabel = <Widget>[] ;

    if(isExpaired){
      expiredLabel.add(const Align(
        alignment: Alignment.centerLeft,
        child:  Text("EXPIRED", style: TextStyle(color: Color.fromARGB(193, 224, 14, 14)))
        )) ;
    }

    
    return InkWell(
      onTap: () => action(budgetId),
      child: SizedBox(
        width: width ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(8),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(33, 179, 177, 180)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(budgetName, style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis
                        ),),
                        const Padding(padding: EdgeInsets.only(bottom: 5)), 
                        Text("$categoryCount categories", style: const TextStyle(fontSize: 12, color: Colors.grey),)
                      ],
                  ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DisplayDate(
                      date: fromDate,
                      label: "From",
                    ),
                  Container(
                    margin: const EdgeInsets.only(left: 3),
                    height: 15,
                    width: 1,
                    color: Colors.grey,
                  ),
                  DisplayDate(
                    date: endDate,
                    label: "To     ",
                    )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(commonUtil.currencyIcon(currencyCode), color: amountColor, size: 14),
                              Text(commonUtil.formatAmount(balanceAmount, currencyCode), style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 17)),
                              Text(" $amountStr1", style: TextStyle(color: amountColor, fontSize: 12, fontWeight: FontWeight.bold))
                            ],
                          ),
                          Row(
                            children: [
                              Text("$amountStr2 ", style: const TextStyle(color: Colors.grey, fontSize: 12),),
                              Icon(commonUtil.currencyIcon(currencyCode), color: Colors.grey, size: 12),
                              Text(commonUtil.formatAmount(totalAmount, currencyCode), style: const TextStyle(color: Colors.grey, fontSize: 12))
                            ],
                          )
                        ],
                      ),
                      CircularChart(
                        perc: (perc.toInt()).toString(),
                        value: perc / 100,
                        textColor: exceedStatus ? Colors.red : Colors.black,
                        color: exceedStatus ? Colors.red : primaryColor.withOpacity(0.65),
                      )
                    ],
                  ),
                  ...expiredLabel
                ],
              ),
            ),
            // const Padding(padding: EdgeInsets.only(bottom: 10)),
            Visibility(
              visible: showActions,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(33, 179, 177, 180),
                  borderRadius: BorderRadius.circular(6)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: (width / 2),
                      child: DeleteButton(
                        fontSize: 13,
                        iconSize: 17,
                        delete: () => deleteBudget(budgetId)
                      )
                    ),
                    SizedBox(
                      width: (width / 2) ,
                      child: EditButton(
                        fontSize: 12,
                        iconSize: 15,
                        action: () => editBudget(budgetData)
                      )
                    )
                  ],
                )
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10))
          ],
        ),
      ),
    ) ;
  }
}


class DisplayDate extends StatelessWidget{
  final String label ;
  final String date ;
  const DisplayDate({super.key, required this.label, required this.date});

  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(50)
          ),
          height: 7,
          width: 7,
        ),
        Text("$label ", style: const TextStyle(fontSize: 13)),
        const Icon(Icons.calendar_month, size: 15, color: Colors.grey,),
        Text(" $date", style: const TextStyle(fontSize: 13))
      ],
    ) ;
  }
}