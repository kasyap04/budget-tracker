import 'package:flutter/material.dart';

import '../../utils/constant.dart';
import '../../utils/common.dart';
import '../../controller/home/homeController.dart';


class TopBar extends StatefulWidget{
  final dynamic homeData ;
  final void Function() gotoNewBudget ;
  final void Function() cardTapped ;
  const TopBar({super.key, required this.homeData, required this.gotoNewBudget, required this.cardTapped});

  @override
  State<StatefulWidget> createState() => TopBarState() ;

}

class TopBarState extends State<TopBar>{
  HomeController homeController = HomeController() ;



  DateTime currentDate    = DateTime.now() ;
  double expense          = 0 ;
  String selectedDate     = "" ;
  Color backgroundColor   = Colors.white ;


  @override
  Widget build(BuildContext context){
    if(widget.homeData != null){
      currentDate   = widget.homeData['date'] ;
      expense       = widget.homeData['expense'] ;
      selectedDate  = widget.homeData['showDate'] ;
    }

    // print(widget.homeData) ;


    return  InkWell(
      onTap: widget.cardTapped,
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            widget.homeData == null ?
            const Text("future") :
              BudgetDate(
                actionBack: datebackward,
                actionForward: dateforward,
                selectedDate: selectedDate,
              ),


              widget.homeData == null ?
              const Text("Loading") :
              Column(
                children: [
                  MainExpenseAmount(
                    amount: expense,
                    currency: widget.homeData['currency'],
                  )
                ],
              ),
             const Text("Total spend", style: TextStyle(color: Colors.grey, fontSize: 12),),

             Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: widget.gotoNewBudget,
                  child:  Container(
                    margin: const EdgeInsets.only(right: 10, bottom: 5),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    color: const Color.fromARGB(255, 108, 64, 117),
                    ),
                    child: const Icon(Icons.add, size: 30, color: Colors.white),
                  ),
                )
              ],
             )
          ],
        ),
      ),
    ) ;
  }

  
  void datebackward() async {
    Map<String, dynamic> monthExpense = await homeController.getPreviousMonthExpense(currentDate) ;
    setState(() {
      widget.homeData['date']     = monthExpense['date'] ;
      widget.homeData['expense']  = monthExpense['expense'] ;
      widget.homeData['showDate'] = monthExpense['showDate'] ;
    });

  }

  void dateforward() async {
    Map<String, dynamic> monthExpense = await homeController.getNextMonthExpense(currentDate) ;
    setState(() {
      widget.homeData['date']     = monthExpense['date'] ;
      widget.homeData['expense']  = monthExpense['expense'] ;
      widget.homeData['showDate'] = monthExpense['showDate'] ;
    });

  }
}


// ignore: must_be_immutable
class MainExpenseAmount extends StatelessWidget{
  CommonUtil common = CommonUtil() ;

  final double amount ;
  final String currency;

  MainExpenseAmount({super.key, required this.amount, required this.currency});
  @override
  Widget build(BuildContext context){
    return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(common.currencyIcon(currency), color: Colors.white, size: 34,),
              Text(common.formatAmount(amount, currency), style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),)
            ],
          ) ;
  }
}


// TOP DATE CONTROLL
// ignore: must_be_immutable
class BudgetDate extends StatelessWidget{
  BudgetDate({super.key, required this.actionBack, required this.actionForward, required this.selectedDate});

  final void Function() actionBack ;
  final void Function() actionForward ;
  Color backgroundColor = Colors.white ;
  final String selectedDate ;

  @override
  Widget build(BuildContext context){
    return             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 ArrowButton(
                  action: actionBack,
                  icon: Icons.arrow_back_ios
                ),
                Text(selectedDate, style: TextStyle(
                  color: backgroundColor, fontSize: 16
                ),),
                ArrowButton(
                  action: actionForward,
                  icon: Icons.arrow_forward_ios
                ),
              ],
            ) ;
  }
}

  // ignore: must_be_immutable
  class ArrowButton extends StatelessWidget{
  ArrowButton({super.key, required this.icon, required this.action});

  final IconData icon ;
  final void Function() action ;

   Color backgroundColor = Colors.white ;


    @override
    Widget build(BuildContext context){
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: IconButton(onPressed: action, icon: Icon(icon), color: backgroundColor)) ;
    }
  }