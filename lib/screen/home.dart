import 'package:budget_tracker/screen/addBudget.dart';
import 'package:budget_tracker/utils/constant.dart';
import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/common/headerText.dart';
import '../widgets/home/topBar.dart';
import '../widgets/home/activeBudgets.dart';
import '../widgets/home/quickExpense.dart';
import '../widgets/chart/columnChart.dart';
import '../controller/home/homeController.dart';
import 'budget.dart';
import 'allBudgets.dart';
import 'addQuickExpense.dart';
import 'quickExpense.dart';
import 'profile.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState() ;
}



class HomePageState extends State<HomePage>{

  HomeController controller = HomeController() ;

  String currencyCode = "" ;


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBarWidget(title: "Budget Tracker", back: false, action: [profileIcon(context)]),
      body: FutureBuilder(
        future: controller.getHomeData(), 
        builder: (context, snapshot){
        
        dynamic topData ;
        dynamic budgets ;

          if(snapshot.hasData){
              topData = snapshot.data ;
              budgets = {'budget' : topData['budgets'], 'currencyCode' : topData['currency']} ;
              currencyCode = topData['currency'] ;
          }


          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              ColumnChart(
                currencyCode: topData == null ? "" : topData['currency'] ,
                isLoading: budgets == null,
                expenseType: 2,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              const Divider(thickness: 1,),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              HeaderText(name: "My budgets", top: 20, bottom: 10), 
              TopBar(
                homeData: topData,
                gotoNewBudget: () => routeAddBudget(context, topData),
                cardTapped: () => routeAllBudgets(context),
              ),
              ActiveBudget(
                editBudgetAction: (value){},
                deleteBudgetAction: (a){},
                budgets: budgets ?? {},
                isLoading: budgets == null,
                showAction: false,
                routeBudget: (budgetId, budgetName) => routeBudget(budgetId, budgetName, topData['currency'], context),
              ),
              HeaderText(name: "Quick expense", top: 20, bottom: 10), 
              QuickExpenseHome(
                currencyCode: topData == null ? "" : topData['currency'],
                addExpenseAction: (cards) =>  routeAddQuickExpense(cards, null),
                showAllAction: () => routeQuickExpense(context),
                editQuickExpense: (expenseData, cards) => routeAddQuickExpense(cards, expenseData),
                deleteQuickExpense: () => setState(() {}),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20))
            ],
      ) ;

        }
        
        ),
    ) ;
  }

  void routeAddBudget(BuildContext context, dynamic topData) async {
      if(topData != null){
        Map<String, dynamic> budgetData = {
          'currencyCode' : topData['currency']
        } ;
        await Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddBudgetPage(budgetData: budgetData,))) ;
      }
      setState(() {});
  }

  void routeBudget(int budgetId, String budgetName, String code, BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => Budget(budgetId: budgetId, budgetName: budgetName, currencyCode: code,) )) ;
    setState(() {});
  }

  void routeAllBudgets(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllBudgets(
          currencyCode: currencyCode,
        )
      )
    ) ;

    setState(() {});
  }


  void routeAddQuickExpense(List<Map> cards, Map<String, dynamic>? expenseData) async {
    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => AddQuickExpense(
          currencyCode: currencyCode,
          cards : cards,
          expenseData: expenseData,
        )
      )
    ) ;
    setState(() {});
  }


  void routeQuickExpense(BuildContext context) async {
    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => QuickExpense(
          currencyCode: currencyCode,
        )
      )
    ) ;
    setState(() {}); 
  }

  Widget profileIcon(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.person, color: primaryColor, size: 35),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(
              currencyCode: currencyCode,
            )
          ) 
        ) ;
        setState(() {});
      }, 
    ) ;
  }

}