import 'package:flutter/material.dart';

import 'budgetList.dart';
import '../../utils/common.dart';

class ActiveBudget extends StatelessWidget{
  final Map budgets ;
  final bool isLoading ;
  final bool showAction ;
  final void Function(int budgetId, String budgetName) routeBudget ;
  final void Function(Map budget) editBudgetAction ;
  final void Function(int budgetId) deleteBudgetAction ;
  ActiveBudget({super.key, required this.budgets, required this.isLoading, required this.routeBudget, required this.showAction, required this.editBudgetAction, required this.deleteBudgetAction});

  final CommonUtil commonUtil = CommonUtil() ;


  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;

    if(isLoading){
      return Text("Loading") ;
    }

    String currencyCode = budgets['currencyCode'] ;
  
  
    List<Widget> children = [] ;
    for (var element in budgets['budget']) {      
      DateTime startDate  = commonUtil.strDateToDateTime(element['start_date']) ;
      DateTime endDate    = commonUtil.strDateToDateTime(element['end_date']) ;
      bool expaired       = endDate.difference(DateTime.now()).inDays <= 0 ;

      children.add(
        BudgetList(
          width: (size.width / 2) - 13, 
          currencyCode:   currencyCode, 
          budgetName:     element['budget_name'], 
          categoryCount:  element['count'], 
          fromDate:       commonUtil.dateTimePrettyFormat(startDate), 
          endDate:        commonUtil.dateTimePrettyFormat(endDate), 
          totalAmount:    element['total_amount'], 
          spentAmount:    element['spend'],
          budgetId:       element['id'],
          isExpaired:     expaired,
          showActions:    showAction,
          action: (budgetId) => routeBudget(budgetId, element['budget_name']),
          budgetData: Map.of(element),
          deleteBudget: (id) => deleteBudgetAction(id),
          editBudget: (budgetData) => editBudgetAction(budgetData),
        )
      ) ;
    }
    
    return Wrap(
      spacing: showAction ? 5 : 0,
      children: children,
    ) ;
  }
}