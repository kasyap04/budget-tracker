import 'package:flutter/material.dart';

import '../expenseHistory/history.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../controller/quickExpenseController.dart';


class QuickExpenseHome extends StatefulWidget{
	final String currencyCode ;
	final void Function(List<Map> cards) addExpenseAction ;
  final void Function() showAllAction ;
  final void Function() deleteQuickExpense ;
  final void Function(Map<String, dynamic> expenseData, List<Map> cards) editQuickExpense ;
	const QuickExpenseHome({super.key, required this.currencyCode, required this.addExpenseAction, required this.showAllAction, required this.editQuickExpense, required this.deleteQuickExpense});

	@override
	State<QuickExpenseHome> createState() => QuickExpenseState() ;
}

class QuickExpenseState extends State<QuickExpenseHome>{
	final QuickExpenseController controller = QuickExpenseController() ;
	final CommonUtil commonUtil 	= CommonUtil() ;

	@override
	Widget build(BuildContext context){
		return FutureBuilder(
			future: controller.getQuickExpenseData(5), 
			builder: (context, snapshot){
        
        List<Map> cards     = [] ;
        List history        = [] ;
        double totalExpense = 0 ;

				dynamic quickExpense ;
				if(snapshot.hasData){
					quickExpense = snapshot.data ;
          cards = quickExpense['cards'] ;
          history = quickExpense['history'] ;

          for (var element in history) {
            totalExpense += element['amount'] ;
          }
				}

				
				return Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											children: [
												Icon(commonUtil.currencyIcon(widget.currencyCode), color: primaryColor),
												Text(commonUtil.formatAmount(totalExpense, widget.currencyCode), style: TextStyle(fontSize: 25, color: primaryColor),)
											],
										),
										const Text("Spend this month", style: TextStyle(color: Colors.grey))
									],
								),
								TextButton.icon(
									onPressed: () => widget.addExpenseAction(cards), 
									icon: Icon(Icons.add, color: primaryColor,),
									label: Text("Add", style: TextStyle(color: primaryColor)),
								)
							],
						),
						History(
							history: history,
							currencyCode: widget.currencyCode, 
							deleteAction: (expenseId, b) => delete(context, expenseId), 
							editAction: (expenseData) => widget.editQuickExpense(expenseData, cards)
						),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 100,
                child: TextButton(
                  onPressed: widget.showAllAction,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Show all", style: TextStyle(color: primaryColor)),
                      const Padding(padding: EdgeInsets.only(left: 5)),
                      Icon(Icons.arrow_forward, color: primaryColor, size: 17)
                    ],
                  ),
                ),
              ),
            )
					],
				) ;
			}
		) ;
	}

    void delete(BuildContext context, int expenseId) async {
      bool status = await controller.deleteExpense(expenseId) ;

      if(!context.mounted) return ;
      if(status){
        widget.deleteQuickExpense() ;
        commonUtil.showSnakBar(context: context, msg: "Expense deleted", error: false) ;
      } else {
        commonUtil.commonError(context) ;
      }
    }
}