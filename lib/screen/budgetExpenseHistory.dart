import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/common/headerText.dart';
import '../widgets/addExpense/budgetExpenseTop.dart';
import '../widgets/expenseHistory/categoryFilterBox.dart';
import '../widgets/expenseHistory/history.dart';
import '../controller/expenseHistoryController.dart';
import '../utils/common.dart';
import 'addBudgetExpense.dart';


class BudgetExpenseHistory extends StatefulWidget{
  final String currencyCode ;
  final Map<String, dynamic> budget ;
  final List catgory ;
  final Map<int, String> selectedCards ;
  final List<String> months ;
  const BudgetExpenseHistory({super.key, required this.currencyCode, required this.budget, required this.catgory, required this.selectedCards, required this.months});

  @override
  State<BudgetExpenseHistory> createState () => BudgetExpenseHistoryState() ;
}

class BudgetExpenseHistoryState extends State<BudgetExpenseHistory>{
  final ExpenseHistoryController historyController = ExpenseHistoryController() ;
  final CommonUtil commonUtil = CommonUtil() ;

  List<int> selectedCategory      = <int>[] ;
  List<String> selectedDates      = <String>[] ;
  Map<String, bool> selectedMonth = <String, bool>{} ;

  List<Map<String, dynamic>> categories         = <Map<String, dynamic>>[];
  Map<int, Map<String, dynamic>> selectedCards  = <int, Map<String, dynamic>>{} ;
  
  double totalSpendTop  = 0 ;
  double totalSpend     = 0 ;


  @override
  void initState(){
    super.initState();
    totalSpendTop = totalSpend = widget.budget['total_spend'] ;

    for (var element in widget.catgory) {
        categories.add({
          'category_name' : element['category_name'],
          'total_amount' : element['total_amount'],
          'amount_spend' : element['amount_spend'],
          'budget_details_id' : element['budget_details_id'],
          'category_id' : element['category_id']
        }) ;
    }

    for (var element in widget.catgory) {
      selectedCategory.add(element['budget_details_id']) ;
    }

    widget.selectedCards.forEach((key, value) {
      selectedCards[key] = {
        'name' : value,
        'active' : true
      } ;
    } ) ;

    for (var element in widget.months) {
      selectedMonth[element] = true ;
    }

  }




  @override
  Widget build(BuildContext context){


    List cardIds = [] ;
    selectedCards.forEach((key, value) {
      if(value['active']){
        cardIds.add(key) ;
      }
    }) ;

    List monthsNumbers = selectedMonth.entries.where((element) => element.value).map((e) => e.key ).toList() ;

    return Scaffold(
        appBar: AppBarWidget(
        back: true,
        title: "Expense history",
        currentContext: context
      ),
      body: FutureBuilder(
        future: historyController.getHistoryPageData(widget.budget['budget_id'], selectedCategory, cardIds, monthsNumbers), 
        builder: (context, snapshot){
          
          List expenseHistory = [] ;

          if(snapshot.hasData){
            dynamic snapData = snapshot.data ; 
            expenseHistory =  snapData['history'];

            totalSpend = 0 ;
            for (var element in expenseHistory) {
                totalSpend += element['amount'] ;
            }

            categories.clear() ;
            for (var element in snapData['category']) {
                categories.add({
                  'category_name' : element['category_name'],
                  'total_amount' : element['total_amount'],
                  'amount_spend' : element['amount_spend'],
                  'budget_details_id' : element['budget_details_id'],
                  'category_id' : element['category_id']
                }) ;
            }
          }

          return ListView(
          padding: const EdgeInsets.all(10),
          children: [
            BudgetExpenseTop(
              categoryName: widget.budget['name'], 
              totalAmount: widget.budget['total_amount'], 
              spendAmount: totalSpendTop , 
              currencyCode: widget.currencyCode
            ),
            CategoryFilterBox(
              category: categories,
              currencyCode: widget.currencyCode,
              selectedCategories: selectedCategory,
              selectedCards: selectedCards,
              selectedMonth: selectedMonth,
              categoryTapped: (budgetDetailId) => categoryTapped(budgetDetailId),
              cardTapped: (cardId) => cardTapped(cardId),
              monthTapped: (month) => monthTapped(month),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderText(name: "Expense history", top: 10),
                Row(
                  children: [
                    Icon(commonUtil.currencyIcon(widget.currencyCode), color: Colors.grey, size: 17,),
                    Text(commonUtil.formatAmount(totalSpend, widget.currencyCode), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                  ],
                )
              ],
            ),
            History(
              history: expenseHistory, 
              currencyCode: widget.currencyCode,
              deleteAction: (expenseId, budgetDetailId) => deleteBudgetExpense(context, expenseId, budgetDetailId),
              editAction: (expenseData) => routeEditExpense(context, expenseData),
            )
          ],
        ) ;
        }
      ),
    ) ;
  }

  void routeEditExpense(BuildContext context, Map<String, dynamic>expenseData) async {
    int expenseId       = expenseData['expense_id'] ;
    List<Map> category  =  await historyController.getBudgetDetails(expenseId) ;
    List<Map> cards     = await historyController.getActiveCards() ;

    if(category.isNotEmpty){
      
      if(!context.mounted) return ;

      dynamic returnValue = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddBudgetExpense(currencyCode: widget.currencyCode, category: category[0], cards: cards, editableValues: expenseData)) ) ;
      if(returnValue != null){
        double amount = double.parse(returnValue) ;

          totalSpendTop += amount ;
        // setState(() {
        // });
      }
      setState(() {});
    }else {
      if(!context.mounted) return ;

      commonUtil.commonError(context) ;
    }
  }

  void deleteBudgetExpense(BuildContext context, int expenseId, int budgetDetailId) async {
    double deleteAmount = await historyController.deleteExpense(context, expenseId, budgetDetailId) ;
    if(deleteAmount > 0){
      setState(() {
        totalSpendTop -= deleteAmount ;
      });
    }

  }

  void categoryTapped(int budgetDetailId){
    setState(() {
      if(selectedCategory.contains(budgetDetailId)){
        selectedCategory.remove(budgetDetailId) ;
      } else {
        selectedCategory.add(budgetDetailId) ;
      }
    });
  }
  void cardTapped(int cardId){
    setState(() {
      selectedCards[cardId]?['active'] = !selectedCards[cardId]?['active'] ;
    });
  }

  void monthTapped(String month){
    setState(() {
      selectedMonth[month] = !selectedMonth[month]! ;
    });
  }

}