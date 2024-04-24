import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/home/activeBudgets.dart';
import '../controller/home/homeController.dart';
import '../utils/common.dart';
import 'budget.dart';
import 'editBudget.dart';


class AllBudgets extends StatefulWidget{
	final String currencyCode ;
	const AllBudgets({super.key, required this.currencyCode});

	@override
	State<AllBudgets> createState() => AllBudgetsState() ;
}

class AllBudgetsState extends State<AllBudgets>{
	final HomeController homeController = HomeController() ;
  final CommonUtil commonUtil = CommonUtil() ;

	@override
	Widget build(BuildContext context){
		return Scaffold(
		appBar: AppBarWidget(title: "All budgets", back: true, currentContext: context),
		body: FutureBuilder(
			future: homeController.getBudgets(orderBy: "b.end_date DESC"),
			builder: (context, snapshot) {
				
				Map budgetData = {} ;
				dynamic allBudgets ;

				if(snapshot.hasData){
					allBudgets = snapshot.data ;
					
					budgetData = {
						'currencyCode' : widget.currencyCode,
						'budget' : allBudgets
					} ;
				
				}

				return ListView(
					padding: const EdgeInsets.all(10),
					children: [
						ActiveBudget(
              editBudgetAction: (budget) => routeEditBudget(context, budget),
              deleteBudgetAction: (budgetId) => deleteBudget(context, budgetId),
							budgets: budgetData, 
							isLoading: allBudgets == null, 
							showAction: true,
							routeBudget: (budgetId, budgetName) => routeBudget(budgetId, budgetName, widget.currencyCode, context)
						)
					],
				) ;
			},
		)
		) ;
	}


  void routeBudget(int budgetId, String budgetName, String code, BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => Budget(budgetId: budgetId, budgetName: budgetName, currencyCode: code,) )) ;
    setState(() {});
  }

  void deleteBudget(BuildContext context, int budgetId) async {
    bool deleteStatus = await homeController.deleteBudget(budgetId) ;

    if(!context.mounted) return ;
    if(deleteStatus){
      setState(() {});
      commonUtil.showSnakBar(context: context, msg: "Budget deleted", error: false) ;
    } else {
      commonUtil.commonError(context) ;
    }
  }


  void routeEditBudget(BuildContext context, Map budget) async {
    dynamic category = await homeController.getCategoryData(budget['id']) ;
    budget['category'] = category ;

    if(!context.mounted) return ;
    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => EditBudget(
          currencyCode: widget.currencyCode, 
          budgetId: budget['id'], 
          budget: budget
        )
      )
    ) ;

    setState(() {});
  }
}