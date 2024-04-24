import 'package:budget_tracker/widgets/common/secondaryButton.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../widgets/common/appbar.dart';
import '../widgets/common/primaryButton.dart';
import '../widgets/addBudget/categoryAmountBalbel.dart';
import '../widgets/addBudget/categoryList.dart';
import '../widgets/addBudget/datePickerWidget.dart';
import '../widgets/form/textInput.dart';
import '../widgets/form/amountField.dart';
import '../utils/common.dart';
import '../controller/addBudget/addBudget.dart';


// ignore: must_be_immutable
class AddBudgetPage extends StatefulWidget{
  final Map<String, dynamic> budgetData ;
  late Map? budget ;
  late int? budgetId ;
  AddBudgetPage({super.key, required this.budgetData, this.budget, this.budgetId});

  @override
  State<AddBudgetPage> createState() => AddBudgetPageState() ;
}

class AddBudgetPageState extends State<AddBudgetPage>{

  final CommonUtil commonUtil = CommonUtil() ;
  final formKey = GlobalKey<FormState>();
  final DateRangePickerController dateRangeController   = DateRangePickerController();
  final TextEditingController budgetNameController      = TextEditingController() ;
  final TextEditingController budgetAmountController    = TextEditingController() ;
  final TextEditingController categoryNameController    = TextEditingController() ;
  final TextEditingController categoryAmountController  = TextEditingController() ;

  final BudgetController budgetController = BudgetController() ; 

  double balanceAmount = 0, expenseAmount = 0 ;
  Color balanceColor = Colors.black, expenseColor = Colors.black ;

  List<Map<String, dynamic>> categories = [] ;

  void removeCategory(int index){
    setState(() {
      categories.removeAt(index) ;
    });
  }



  @override
  void initState(){
    super.initState();

    if(widget.budget != null){
      Map budget = widget.budget! ;

      budgetNameController.text   = budget['budget_name'] ;
      budgetAmountController.text = budget['total_amount'].toString() ; 

      DateTime startDate  = commonUtil.strDateToDateTime(budget['start_date']) ;
      DateTime endDate    = commonUtil.strDateToDateTime(budget['end_date']) ; 
      dateRangeController.selectedRange = PickerDateRange(startDate, endDate) ;

      for (var element in budget['category']) {
        categories.add({
          'name' : element['category_name'],
          'amount' : element['total_amount'],
          'type' : 'old'
        }) ;
      }

    }

  }



  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;

    String currencyCode = widget.budgetData['currencyCode'] ;
    final budgetLabels  = budgetController.calCategoryAmount(budgetAmountController.text, categories) ;
    balanceAmount       = budgetLabels.$1 ;
    expenseAmount       = budgetLabels.$2 ;


    return Scaffold(
      appBar: AppBarWidget(
        back: true, 
        title: widget.budget == null ? "Add Budget" : "Edit category" , 
        currentContext: context
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          DatePickerWidget(
            controller: dateRangeController,
          ),

          Form(
            key: formKey,
            child: Column(
              children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextInputFeild(controller: budgetNameController,
                     label: "Budget name", 
                     width: (size.width / 2) - 20,
                     validator: (value) => commonUtil.inputValidator(value, msg: "Please enter budget name"),
                     ),
                    AmountFeild(controller: budgetAmountController, 
                    countryCode: currencyCode,
                    label: "Budget amount",
                     width: (size.width / 2) - 20,
                     validator: (value) => commonUtil.inputAmountValidator(value, msg: "Please enter budget amount"),
                     ),
                  ],
                ),

                Container(
                  padding:const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(61, 158, 158, 158)
                  ),
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CategoryAmountLabel(
                            currencyCode: currencyCode,
                            amount: balanceAmount, 
                            label: 'Balance',
                            color: balanceColor,
                          ),
                          CategoryAmountLabel(
                            label: 'Expense',
                            currencyCode: currencyCode,
                            amount: expenseAmount,
                            color: expenseColor,
                          ),
                        ],
                      ),
                      CategoryList(
                        categories: categories,
                        currencyCode: currencyCode,
                        removeAction: (index) => removeCategory(index) ,
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextInputFeild(controller: categoryNameController, 
                    label: "Category name",
                    width: (size.width / 2) - 20,
                    validator: (value) => commonUtil.inputValidator(value, msg: "Please enter category name"),
                    ),
                    AmountFeild(controller: categoryAmountController, 
                    countryCode: currencyCode,
                    label: "Category amount",
                    width: (size.width / 2) - 20,
                    validator: (value) => commonUtil.inputAmountValidator(value, msg: "Please enter category amount"),
                    )
                  ],
                ),
                SecondaryButton(
                  buttonName: "Add category",
                  width: size.width,
                  action: () => addCategory(context) ,
                  top: 15,
                ),
                PrimaryButton(
                  buttonName: widget.budget == null ? "Create budget" : "Save new categories",
                  width: size.width,
                  action: () => widget.budget == null ? saveNewBudget(context) : saveNewCategories(context),
                  top: 15,
                )
              ],
            ),
          ),
        ],
      ),
    ) ;
  }


  void addCategory(BuildContext context){
    if(formKey.currentState!.validate()){
      String name = categoryNameController.text, amount = categoryAmountController.text ;

      try{
        setState(() {
          categories.add({
          'name': name,
          'amount' : double.parse(amount.toString()),
          'type' : 'new',   // adding new category (not chosen from db)
          'category_id' : 0
          }) ;
        });
      }catch(e){
        commonUtil.commonError(context) ;
      }

      categoryNameController.text = categoryAmountController.text = "" ;

      if(balanceAmount < 0){
        commonUtil.showSnakBar(context: context, msg: "Category amount exceeds the budgeted amount", error: false) ;
      }
    }
  }

  dynamic saveNewBudget(BuildContext context) async {
    if(categories.isEmpty){
        commonUtil.showSnakBar(context: context, msg: "Categories not found, Please add some categories", error: true) ;
        return false ;
    }

    if(dateRangeController.selectedRange == null){
        commonUtil.showSnakBar(context: context, msg: "Please choose budget dates", error: true) ;
        return false ;
    } 


    late DateTime? startDate  = dateRangeController.selectedRange!.startDate ;
    late DateTime? endDate    = dateRangeController.selectedRange!.endDate ;
    String budgetName         = budgetNameController.text, 
          budgetAmount        = budgetAmountController.text ;

    Map<String, dynamic> budgetDetails = {
      'start_date' : startDate,
      'end_date' : endDate ?? startDate,
      'budget_name' : budgetName,
      'budget_amount' : double.parse(budgetAmount.toString()),
      'category' : categories
    } ;


    if(!context.mounted) return ;

    await budgetController.saveBudget(budgetDetails)
    .then((value) {
      commonUtil.showSnakBar(context: context, msg: "New budget created", error: false) ;

      setState(() {
          categories.clear() ;
          budgetNameController.text   = "" ;
          budgetAmountController.text = "" ;
      });
    })
    .onError((error, stackTrace) {
      commonUtil.commonError(context) ;
    }) ;
  }

  dynamic saveNewCategories(BuildContext context) async {

    bool status = await budgetController.saveEditedCategory(widget.budgetId!, categories) ;

    if(!context.mounted) return ;

    if(status){
      for (var element in categories) {
        element['type'] = 'old' ;
      }
      commonUtil.showSnakBar(context: context, msg: "New categories added", error: false) ;
    } else {
      commonUtil.commonError(context) ;
    }

    setState(() {});

  }


}