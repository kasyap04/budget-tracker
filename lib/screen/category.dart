import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/common/headerText.dart';
import '../widgets/common/deleteButton.dart';
import '../widgets/common/editButton.dart';
import '../widgets/budget/categoryList.dart';
import '../widgets/expenseHistory/history.dart';
import '../controller/expenseHistoryController.dart';
import '../utils/common.dart';
import 'addBudgetExpense.dart';
import 'editCategory.dart';


class Category extends StatefulWidget{
  final String currencyCode ;
  final Map category ;
  final List<Map> cards ;
  final int budgetDetailId ;
  final Map budget ;
  const Category({super.key, required this.currencyCode, required this.category, required this.cards, required this.budgetDetailId, required this.budget});


  @override
  State<Category> createState() => CategoryState() ;
}

class CategoryState extends State<Category>{
  final ExpenseHistoryController historyController = ExpenseHistoryController() ;
  final CommonUtil commonUtil = CommonUtil() ;

  Map changableCategory = {} ;

  @override
  void initState(){
    super.initState();
    changableCategory = Map.of(widget.category) ;
  }

  List<Widget> futureChildren = <Widget>[] ;

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBarWidget(
        back: true,
        title: "Category",
        currentContext: context,
      ),
      body: FutureBuilder(
        future: historyController.getHistoryData([widget.budgetDetailId], null, null), 
        builder: (context, snapshot){
          if(snapshot.hasData){

            dynamic history = snapshot.data ;
            
            double totalSpend = 0 ;
            for (var element in history) {
                totalSpend += element['amount'] ;
            }
            changableCategory['amount_spend'] = totalSpend ;



            futureChildren.clear() ;

            futureChildren.add(
              History(
                history: history, 
                currencyCode: widget.currencyCode,
                deleteAction: (expenseId, budgetDetailId) => deleteBudgetExpense(context, expenseId, budgetDetailId),
                editAction: (expenseData) => routeEditExpense(context, expenseData),
              )
            ) ;

          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              CategoryList(
                countryCode:  widget.currencyCode,
                category: changableCategory,
                categoryClicked: (budgetDetailId, category) => {},
                addExpenseClicked: (category) => routeAddExpense(context, category, widget.cards),

              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8)
                ),
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DeleteButton(
                      delete: () async {
                          bool deleteStatus = await historyController.deleteCategory(widget.budgetDetailId) ;
                            if(!context.mounted) return ;
                              commonUtil.showSnakBar(context: context, msg: "Category deleted", error: false) ;
                              if(deleteStatus){
                                Navigator.pop(context) ;
                              } else {
                                commonUtil.commonError(context) ;
                              }
                      },
                    ),
                    EditButton(
                      action: () => routeEditCategory(context)
                    )
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              const Divider(thickness: 1),
              HeaderText(name: "History", top: 20, bottom: 20),
              ...futureChildren
            ],
          ) ;

        }
      ),
    ) ;
  }

  void routeEditCategory(BuildContext context) async {
    dynamic returnValue = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategory(
          countryCode: widget.currencyCode,
          budgetData : widget.budget,
          category : changableCategory
        )
      )
    ) ;

    if(returnValue != null && returnValue.isNotEmpty){
      setState(() {
        changableCategory['category_name'] = returnValue['budget_name'] ;
        changableCategory['total_amount'] = returnValue['total_amount'] ;
      });
    }
  }

  void deleteBudgetExpense(BuildContext context, int expenseId, int budgetDetailId) async {
    double deleteAmount = await historyController.deleteExpense(context, expenseId, budgetDetailId) ;
    if(deleteAmount > 0){
      setState(() {});
    }

  }

  void routeEditExpense(BuildContext context, Map<String, dynamic>expenseData) async {
    int expenseId       = expenseData['expense_id'] ;
    List<Map> category  =  await historyController.getBudgetDetails(expenseId) ;
    List<Map> cards     = await historyController.getActiveCards() ;

    if(category.isNotEmpty){
      
      if(!context.mounted) return ;

      await Navigator.push(context, MaterialPageRoute(builder: (context) => AddBudgetExpense(currencyCode: widget.currencyCode, category: category[0], cards: cards, editableValues: expenseData)) ) ;

      setState(() {});
    }else {
      if(!context.mounted) return ;

      commonUtil.commonError(context) ;
    }
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
}