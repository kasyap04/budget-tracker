import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/common/headerText.dart';
import '../widgets/chart/columnChart.dart';
import '../widgets/expenseHistory/history.dart';
import '../utils/common.dart';
import '../utils/constant.dart';
import '../controller/quickExpenseController.dart' ;
import 'addQuickExpense.dart';





class QuickExpense extends StatefulWidget{
  final String currencyCode ;
  const QuickExpense({super.key, required this.currencyCode});

  @override
  State<QuickExpense> createState() => QuickExpenseState() ;
}

class QuickExpenseState extends State<QuickExpense> {
  final QuickExpenseController expenseController = QuickExpenseController() ;
  final CommonUtil commonUtil = CommonUtil() ;

  List<Map> cards = [] ;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: "Quick expense",
        back: true,
        currentContext: context,
        action: [
          addExpenseButton(context)
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ColumnChart(
            currencyCode: widget.currencyCode, 
            isLoading: false,
            expenseType: 1,
          ),
          FutureBuilder(
            future: expenseController.getQuickExpenseData(null), 
            builder: (context, snapshot){

                cards     = [] ;
                List history        = [] ;
                double totalExpense = 0 ;

                if(snapshot.hasData){
                  dynamic snapData = snapshot.data ;
                  history = snapData['history'] ;
                  cards   = snapData['cards'] ;

                  for (var element in history) {
                    totalExpense += element['amount'] ;
                  }
                }

                return Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 30)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HeaderText(
                          name: "Expense history",
                        ),
                        Row(
                          children: [
                            Icon(commonUtil.currencyIcon(widget.currencyCode), size: 17, color: primaryColor),
                            Text(commonUtil.formatAmount(totalExpense, widget.currencyCode), style: TextStyle(
                              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold
                            ))
                          ],
                        )
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    History(
                      history: history,
                      currencyCode: widget.currencyCode,
                      deleteAction: (expenseId, b) => deleteExpense(expenseId),
                      editAction: (expenseData) => routeAddQuickExpense(context, cards, expenseData),
                    )
                  ],
                ) ;

            }
          ),
        ],
      ),
    ) ;
  }


  void deleteExpense(int expenseId) async {
      bool status = await expenseController.deleteExpense(expenseId) ;

      if(!context.mounted) return ;
      if(status){
        commonUtil.showSnakBar(context: context, msg: "Expense deleted", error: false) ;
        setState(() {});
      } else {
        commonUtil.commonError(context) ;
      }
  }

  void routeAddQuickExpense(BuildContext context, List<Map> cards, Map<String, dynamic>? expenseData) async {
    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => AddQuickExpense(
          currencyCode: widget.currencyCode,
          cards : cards,
          expenseData: expenseData,
        )
      )
    ) ;
    setState(() {});
  }

  Widget addExpenseButton(BuildContext context){
    return IconButton(
      onPressed: () => routeAddQuickExpense(context, cards, null), 
      icon: Icon(Icons.add_box_outlined, color: primaryColor,),
    ) ;
  }

}