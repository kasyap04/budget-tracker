import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/addExpense/budgetExpenseTop.dart';
import '../widgets/form/amountField.dart';
import '../widgets/form/textInput.dart';
import '../widgets/common/primaryButton.dart';
import '../utils/common.dart';
import '../controller/budgetController.dart';



class EditCategory extends StatefulWidget{
  final String countryCode ;
  final Map budgetData;
  final Map category ;
  const EditCategory({super.key, required this.countryCode, required this.budgetData, required this.category});

  @override
  State<EditCategory> createState() => EditCategoryState() ;
}



class EditCategoryState extends State<EditCategory>{
  final formKey = GlobalKey<FormState>();

  final BudgetController budgetController       = BudgetController() ;
  final TextEditingController nameController    = TextEditingController() ;
  final TextEditingController amountController  = TextEditingController() ;

  final CommonUtil commonUtil = CommonUtil() ;


  double categoryAmount = 0 ;
  double totalAssigned  = 0 ;
  Map budget        = {} ;
  Map returnValue   = {} ;

  @override
  void initState(){
    super.initState();
    budget = Map.of(widget.budgetData) ;

    nameController.text   = widget.category['category_name'] ;
    amountController.text = widget.category['total_amount'].toString() ;

    categoryAmount = widget.category['total_amount'] ;
    totalAssigned  = 0 ;
    for (var element in budget['category']) {
      totalAssigned += element['total_amount'] ;
    }
  }

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;

    double balanceAmount = budget['total_amount'] - totalAssigned ;
    bool exceedStatus = false ;
    if(balanceAmount < 0){
      exceedStatus = true ;
      balanceAmount = totalAssigned - budget['total_amount'] ;
    }

    return Scaffold(
      appBar:  AppBarWidget(
        back: true,
        title: "Edit category",
        currentContext: context,
        returnValue: returnValue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          BudgetExpenseTop(
            categoryName: budget['budget_name'], 
            totalAmount: budget['total_amount'], 
            spendAmount: budget['spend'] , 
            currencyCode: widget.countryCode
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                commonUtil.amountAndLabel(label: "Total category assigned", code: widget.countryCode, amount: totalAssigned, size: 16, color: Colors.black, lableColor: Colors.grey),
                commonUtil.amountAndLabel(label: exceedStatus ? "Exceeded" : "Balance in budget", code: widget.countryCode, amount: balanceAmount, size: 16, color: exceedStatus ? Colors.red : Colors.black, lableColor: exceedStatus ? Colors.red : Colors.grey),
              ],
            ),
          ),
          Form(
            key: formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextInputFeild(
                  label: "Category name",
                  controller: nameController,
                  width: (size.width / 2) - 15,
                  validator: (value) => commonUtil.inputValidator(value, msg: "Please enter category name"),
                ),
                AmountFeild(
                  controller: amountController, 
                  countryCode: widget.countryCode,
                  label: "Category amount",
                  width: (size.width / 2) - 15,
                  validator: (value) => budgetController.validateCategoryAmount(value, categoryAmount, totalAssigned, budget['total_amount'], context),
                )
              ],
            )
          ),
          gap(30),
          PrimaryButton(
            buttonName: "Save category", 
            action: () => save(context)
          )
        ],  
      ),
    ) ;
  }

  void save(BuildContext context) async {
    if(!formKey.currentState!.validate()) return ; 

    String name   = nameController.text ;
    double amount = double.parse(amountController.text) ;

    int budgetDetailId  = widget.category['budget_details_id'],  
        categoryId      = widget.category['category_id'] ;

    bool status = await budgetController.editCategory(budgetDetailId, categoryId, name, amount) ;
    if(!context.mounted) return ;

    if(status){
      commonUtil.showSnakBar(context: context, msg: "Category changes are saved", error: false) ;
      
      setState(() {
        totalAssigned += amount - categoryAmount ;
        categoryAmount = amount ;
        returnValue = {
          'budget_name' : name,
          'total_amount' : amount
        } ;
      });
    } else {
      commonUtil.commonError(context) ;
    }
  }

  Widget gap(double width) => Padding(padding: EdgeInsets.only(bottom: width)) ;
}