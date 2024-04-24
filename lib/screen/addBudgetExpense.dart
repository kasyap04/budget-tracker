import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/common/primaryButton.dart';
import '../widgets/form/dateSelector.dart';
import '../widgets/form/cardSelector.dart';
import '../widgets/addExpense/budgetExpenseTop.dart';
import '../widgets/addExpense/amountInput.dart';
import '../widgets/addExpense/descriptionInput.dart';
import '../utils/common.dart';
import '../controller/addExpenseController.dart';




// ignore: must_be_immutable
class AddBudgetExpense extends  StatefulWidget{
  final String currencyCode ;
  final Map category ;
  final List<Map> cards ;
  late Map<String, dynamic>? editableValues ;
  AddBudgetExpense({super.key, required this.currencyCode, required this.category, required this.cards, this.editableValues});

  @override
  State<AddBudgetExpense> createState() => AddBudgetExpenseState() ;
}

class AddBudgetExpenseState extends State<AddBudgetExpense>{
  final TextEditingController amountController        = TextEditingController() ;
  final TextEditingController descritpionController   = TextEditingController() ;
  final TextEditingController dateController          = TextEditingController();
  final AddExpenseController controller               = AddExpenseController() ;
  final CommonUtil commonUtil                         = CommonUtil() ;

  String cardValue = "0" ;

  String categoryName   = "" ;
  double totalAmount    = 0,  totalSpend        = 0 ;
  int categoryId        = 0,  budgetDetailId    = 0 ;

  late double? oldAmount ;
  late double changesAmount = 0 ;
  late int? expenseId ;

  @override
  void initState(){
    super.initState();

    categoryName    = widget.category['category_name'] ;
    totalAmount     = widget.category['total_amount'] ;
    totalSpend      = widget.category['amount_spend'] ;
    categoryId      = widget.category['category_id'] ;
    budgetDetailId  = widget.category['budget_details_id'] ;


    if(widget.editableValues != null){
      oldAmount                   = widget.editableValues!['amount'] ;
      expenseId                   = widget.editableValues!['expense_id'] ;
      amountController.text       = widget.editableValues!['amount'].toString() ;
      descritpionController.text  = widget.editableValues!['description'] ;
      dateController.text         = widget.editableValues!['date'] ;
      cardValue                   = widget.editableValues!['card'] == null ? "0" : widget.editableValues!['card'].toString() ;
    }


  }



  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;
    
    return Scaffold(
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: PrimaryButton(
            buttonName: widget.editableValues == null ? "Add expense" : "Save changes", 
            action: () =>  saveExpense(context, widget.editableValues == null) 
          ),
      ),
      appBar: AppBarWidget(
        back: true,
        title: widget.editableValues == null ? "Add expense" : "Edit expense",
        currentContext: context,
        returnValue: changesAmount.toString(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          BudgetExpenseTop(
            categoryName: categoryName,
            spendAmount: totalSpend,
            totalAmount: totalAmount,
            currencyCode: widget.currencyCode,
          ),
          const Padding(padding: EdgeInsets.only(bottom: 50)),
          Column(
            children: [
              AmountInput(
                icon: commonUtil.currencyIcon(widget.currencyCode),
                controller: amountController,
              ) ,
              DescriptionInput(
                controller: descritpionController,
                hintText: "Add a description",
                width: size.width / 2,
              )
            ],
          ),
          const Padding(padding: EdgeInsets.only(bottom: 50)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DateSelector(
                initialDate: DateTime.now(),
                firstDate: DateTime(2019),
                lastDate: DateTime.now(),
                controller: dateController,
                label: "Select date",
                width: (size.width / 2) - 15,
                selectDate: true,
              ),
              CardSelector(
                width: (size.width / 2) - 15,
                label: "Select card",
                selectedCardId: cardValue == "0" ? "" : cardValue ,
                menuItems: widget.cards,
                cardChanged: (cardId) => cardValue = cardId ,
              )
            ],
          )
        ],
      ),
    ) ;
  }


  dynamic saveExpense(BuildContext context, bool newExpense) async {
    if(commonUtil.inputAmountValidator(amountController.text) != null){
      commonUtil.showSnakBar(context: context, msg: "Please enter valid amount", error: true) ;
      return false ;
    }
    dynamic description = descritpionController.text ;
    double amount       = double.parse(amountController.text) ;
    String date         = dateController.text ;
    
    if(amount <= 0){
      commonUtil.showSnakBar(context: context, msg: "Amount bust be greater than 0", error: true) ;
      return false ;
    }

    dynamic status = false ;
    if(newExpense){
        status = await controller.saveNewBudgetExpense(context, amount, description, date, cardValue, categoryId,  budgetDetailId) ;
    } else {
        status = await controller.editBudgetExpense(context, amount, description, date, cardValue, categoryId,  budgetDetailId, oldAmount!, expenseId!) ;
    }

    if(status != null || status != false){

      if(!newExpense) changesAmount = status ;


      if(widget.editableValues == null){
        amountController.text       = "" ;
        descritpionController.text  = "" ;
        dateController.text         = "" ;
        cardValue                   = "0" ;
      }

      if(!context.mounted) return ;
      List categoryData = await controller.getCategoryData(context, budgetDetailId) ;

      if(categoryData.isNotEmpty){
        setState(() {
          totalAmount = categoryData[0]['total_amount'] ;
          totalSpend  = categoryData[0]['amount_spend'] ; 
        });
      }
      
      if(!context.mounted) return ;
      commonUtil.showSnakBar(context: context, msg: "Expense added", error: false) ;
    }

  }
}
