import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/common/headerText.dart';
import '../widgets/common/listButton.dart';
import '../widgets/budget/topCard.dart';
import '../widgets/budget/categoryList.dart';
import '../widgets/budget/categoryGraph.dart';
import '../controller/budgetController.dart';
import '../controller/expenseHistoryController.dart';
import '../utils/constant.dart';
import 'addBudgetExpense.dart';
import 'budgetExpenseHistory.dart';
import 'editBudget.dart';
import 'category.dart';


class Budget extends StatefulWidget{
  final int budgetId ;
  final String budgetName ;
  final String currencyCode ;
  const Budget({super.key, required this.budgetId, required this.budgetName, required this.currencyCode});

  @override
  State<Budget> createState() => BudgetState() ;
}

class BudgetState extends State<Budget>{
  final BudgetController controller = BudgetController() ;
  final ExpenseHistoryController historyController = ExpenseHistoryController() ;

  String screenHeader = "";

  Map<int, String> allCards          = <int, String>{} ;
  Map<int, String> selectedCards     = <int, String>{} ;
  List<String> months = <String>[] ;

  @override
  void initState(){
    super.initState();
    screenHeader = widget.budgetName ;
  }


    void setCards() async {
      Map<String, dynamic> details = await historyController.getSpendCardsAndDates(widget.budgetId) ;
      months = details['months'] ;

      for (var element in details['cards']) {
        selectedCards[element['id']] = element['card_name'];
      }

  }



  @override
  Widget build(BuildContext context){
    setCards() ;

    return Scaffold(
      appBar: AppBarWidget(
        back: true,
        title: screenHeader,
        currentContext: context,
        action: getActions(),
      ),
      body: FutureBuilder(
      future: controller.getBudgetDetails(context, widget.budgetId),
      builder: (context, snapshot){

        bool isLoading      = true ;
        dynamic budgetData  = {} ;
        List<Map> cards     = [] ;

        if(snapshot.hasData){
          isLoading     = false ;
          budgetData    = snapshot.data ;
          screenHeader  = budgetData['budget_name'] ;
          cards         = budgetData['cards'] ;
        }

        if(isLoading){
          return Text("Loading") ;
        }


        // print(budgetData) ;

        List<Widget> children = <Widget>[
            BudgetTopCard(
              currencyCode: widget.currencyCode,
              endDate: budgetData['end_date'],
              startDate: budgetData['start_date'],
              spend: budgetData['spend'],
              totalAmount: budgetData['total_amount'],
              isLoading: isLoading,
            ),
            CategoryGraph(
              totalSpend: budgetData['spend'],
              category: budgetData['category'],
              totalAmount: budgetData['total_amount'],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider( thickness: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderText(name: "Categories"),
                ListButton(
                  icon: Icons.list,
                  label: "Expense history", 
                  action: () => routeExpenseHistory(context, budgetData))
              ],
            )
            
        ] ;

        for (var element in budgetData['category']) {
          children.add(CategoryList(
            countryCode:  widget.currencyCode,
            category:     element,
            categoryClicked: (budgetDetailId, category) => routeCategory(context, budgetDetailId, category, cards, budgetData),
            addExpenseClicked: (category) => routeAddExpense(context, category, cards),

          )) ;
        }

        return ListView(
          padding: const EdgeInsets.all(10),
          children: children,
        ) ;
      },
    ),
    ) ;
  }

  void routeCategory(BuildContext context, int budgetDetailId, Map category, List<Map> cards, Map budgetData) async {
    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => Category(
          currencyCode: widget.currencyCode,
          category: category,
          cards: cards,
          budgetDetailId: budgetDetailId,
          budget: budgetData,
        )
      )
    ) ;

    setState(() {});
  }


  void routeAddExpense(BuildContext context, Map category, List<Map> cards) async {
    await Navigator.push(context, 
      MaterialPageRoute(builder: (context) => AddBudgetExpense(
        category: category,
        currencyCode: widget.currencyCode,
        cards: cards,
      ) )
    ) ;
    setState(() {});
  }


  void routeExpenseHistory(BuildContext context, Map budget) async {
    await Navigator.push(context, 
      MaterialPageRoute(builder: (context) => BudgetExpenseHistory(
        currencyCode: widget.currencyCode,
        budget: {
          'budget_id'      : widget.budgetId,
          'name'          : budget['budget_name'],
          'total_amount'  : budget['total_amount'],
          'total_spend'   : budget['spend']
        },
        catgory: budget['category'],
        selectedCards: selectedCards,
        months: months,
      ) )
    ) ;
    setState(() {});
  }

  void routeEditBudget() async {

    Map budget = await controller.getBudgetDetails(context, widget.budgetId) ;

    if(!context.mounted) return ;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBudget(
          currencyCode: widget.currencyCode,
          budgetId: widget.budgetId,
          budget: budget,
        )
        )
    ) ;

    dynamic budgetName = await controller.getBudgetName(widget.budgetId) ;

    setState(() {
      if(budgetName != null){
        screenHeader = budgetName ;
      }
    });
  }

  List<Widget> getActions(){
    return [
      TextButton(onPressed: () => routeEditBudget(), 
      child: Row(
        children: [
          Icon(Icons.edit, color: primaryColor, size: 16,),
          const Padding(padding: EdgeInsets.only(left: 5)),
          Text("Edit", style: TextStyle(color: primaryColor),)
        ],
      )
      )
    ] ;
  }

}