import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/form/amountField.dart';
import '../widgets/form/dateSelector.dart';
import '../widgets/form/textInput.dart';
import '../widgets/common/primaryButton.dart';
import '../utils/common.dart';
import '../utils/constant.dart';
import '../controller/budgetController.dart';
import 'addBudget.dart';

class EditBudget extends StatefulWidget{
  final String currencyCode ;
  final int budgetId ;
  final Map budget ;
  const EditBudget({super.key, required this.currencyCode, required this.budgetId, required this.budget});

  @override
  State<EditBudget> createState() => EditBudgetState() ;
}

class EditBudgetState extends State<EditBudget>{

  final formKey = GlobalKey<FormState>();

  final BudgetController budgetController             = BudgetController() ;
  final TextEditingController budgetNameController    = TextEditingController() ;
  final TextEditingController budgetAmountController  = TextEditingController() ;
  final TextEditingController fromDateController      = TextEditingController() ;
  final TextEditingController toDateController        = TextEditingController() ;

  final CommonUtil commonUtil = CommonUtil() ;

  double totalSpend = 0  ;
  List categories   = [] ;
  
  @override
  void initState(){
    super.initState();
    
    budgetNameController.text   = widget.budget['budget_name'] ;
    budgetAmountController.text = widget.budget['total_amount'].toString() ;
    fromDateController.text     = widget.budget['start_date'].substring(0, 10) ;
    toDateController.text       = widget.budget['end_date'].substring(0, 10) ;

    totalSpend  = widget.budget['spend'] ;
  }


  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;

    return Scaffold(
      appBar: AppBarWidget(
        back: true,
        title: "Edit budget",
        currentContext: context,
      ),
      body: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              Form(
                key: formKey,
                child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextInputFeild(
                            controller: budgetNameController,
                            label: "Budget name",
                            width: (size.width  / 2) - 15,
                            validator: (value) => commonUtil.inputValidator(value, msg: "Please enter budget name"),
                          ),
                          AmountFeild(
                            countryCode: widget.currencyCode,
                            controller: budgetAmountController,
                            label: "Budget amount",
                            width: (size.width  / 2) - 15,
                            validator: (value) => budgetController.validateBudgetAmount(value, totalSpend, context),
                          ), 
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DateSelector(
                            label: "Start date", 
                            controller: fromDateController, 
                            width: (size.width  / 2) - 15, 
                            firstDate: DateTime(2019), 
                            lastDate:  DateTime(DateTime.now().year + 5), 
                            initialDate:  DateTime.now(),
                            validator: (value) => commonUtil.inputValidator(value, msg: "Please enter from date"),
                            
                          ),
                          DateSelector(
                            label: "End date", 
                            controller: toDateController, 
                            width: (size.width  / 2) - 15, 
                            firstDate: DateTime(2019), 
                            lastDate:  DateTime(DateTime.now().year + 5), 
                            initialDate:  DateTime.now(),
                            validator: (value) => budgetController.validateToDate(value, fromDateController.text),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                          onPressed: () => routeAddBudget(context), 
                          child: Row(
                            children: [
                              Icon(Icons.add, color: primaryColor,),
                              Text("Edit category", style: TextStyle(color: primaryColor),)
                            ],
                          )
                          )
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 10)),
                      PrimaryButton(
                        width: size.width,
                        buttonName: "Save changes", 
                        action: () => saveBudget(context)
                      )
                    ],
                ),
              ),
            ],
          )
    ) ;
  }

  void routeAddBudget(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBudgetPage(
          budgetData: {
            'currencyCode' : widget.currencyCode,
          },
          budget: widget.budget,
          budgetId: widget.budgetId,
        )
      )
    ) ;
  }

  Future<void> saveBudget(BuildContext context) async {
    if(formKey.currentState!.validate()){
      String budgetName   = budgetNameController.text ;
      double amount       = double.parse(budgetAmountController.text) ;
      String startDate    = fromDateController.text ;
      String toDate       = toDateController.text ;

      Map<String, dynamic> budget = {
        'budget_name'   : budgetName,
        'start_date'    :  startDate.trim().length == 10 ? "$startDate 00:00:00" : startDate,
        'end_date'      : toDate.trim().length == 10 ? "$toDate 00:00:00" : toDate ,
        'total_amount'  : amount
      } ;

      bool status = await budgetController.saveEditedBudget(widget.budgetId, budget) ;

      if(!context.mounted) return ;
      if(status){
          widget.budget['total_amount'] = amount ;
          commonUtil.showSnakBar(context: context, msg: "Budget changes are saved", error: false) ;
      } else {
        commonUtil.commonError(context) ;
      }


    }
  }

}