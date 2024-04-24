import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/common/primaryButton.dart';
import '../widgets/form/dateSelector.dart';
import '../widgets/form/cardSelector.dart';
import '../widgets/addExpense/amountInput.dart';
import '../widgets/addExpense/descriptionInput.dart';
import '../controller/quickExpenseController.dart';
import '../utils/common.dart';


// ignore: must_be_immutable
class AddQuickExpense extends StatefulWidget{
	final String currencyCode ;
  final List<Map> cards ;
  late Map<String, dynamic>? expenseData ;
  AddQuickExpense({super.key, required this.currencyCode, required this.cards, this.expenseData});

	@override
	State<AddQuickExpense> createState() => AddQuickExpenseState() ;
}

class AddQuickExpenseState extends State<AddQuickExpense>{

	final GlobalKey<FormState> formKey  = GlobalKey<FormState>();
  final CommonUtil commonUtil         = CommonUtil() ;

  final QuickExpenseController expenseController      = QuickExpenseController() ;
	final TextEditingController amountController			 	= TextEditingController() ;
	final TextEditingController nameController 					= TextEditingController() ;
	final TextEditingController descriptionController 	= TextEditingController() ;
	final TextEditingController dateController 					= TextEditingController() ;


  String cardValue = "0" ;

  @override
  void initState(){
    super.initState();

    if(widget.expenseData != null){
      Map<String, dynamic> expense = widget.expenseData! ; 

      amountController.text       = expense['amount'].toString() ;
      nameController.text         = expense['category_name'] ;
      dateController.text         = expense['date'] ;
      descriptionController.text  = expense['description'] ;
      cardValue = expense['card'] == null ? "0" : expense['card'].toString() ;
    }
    
  }


	@override
	Widget build(BuildContext context){
		Size size = MediaQuery.of(context).size ;

		return Scaffold(
			backgroundColor: Colors.white,
			bottomNavigationBar: PrimaryButton(
				buttonName: widget.expenseData == null ? "Save expense" : "Save changes", 
				action: () => saveExpense(context),
				bottom: 10,
				left: 10,
				right: 10,
			),
			appBar: AppBarWidget(
        title: widget.expenseData == null ? "Add quick expense" : "Edit quick expense", 
        back: true, 
        currentContext: context
      ),
			body: ListView(
				padding: const EdgeInsets.all(10),
				children: [
					Form(
						key: formKey,
						child: Column(
						children: [
							gap(50),
							AmountInput(
                icon: commonUtil.currencyIcon(widget.currencyCode),
								controller: amountController
							),
							gap(20),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									DescriptionInput(
										controller: nameController,
										hintText: "Spend for",
										width: (size.width / 2) - 15,
                    validator: (value) => commonUtil.inputValidator(value),
									),
									DescriptionInput(
										controller: descriptionController,
										hintText: "Add description",
										width: (size.width / 2) - 15,
									)
								],
							),
							gap(30),
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
										selectedCardId: cardValue,
										menuItems: widget.cards,
										cardChanged: (cardId) => cardValue = cardId ,
									)
								],
							)
						],
						),
					)
				],
			),
		) ;
	}

  dynamic saveExpense(BuildContext context) async {
    try{
      if(!formKey.currentState!.validate()) return ; 
    }catch(e){}


    if(commonUtil.inputAmountValidator(amountController.text) != null){
      commonUtil.showSnakBar(context: context, msg: "Please enter valid amount", error: true) ;
      return false ;
    }

    if(commonUtil.inputValidator(nameController.text) != null) return ;

    dynamic description = descriptionController.text ;
    dynamic name        = nameController.text ;
    double amount       = double.parse(amountController.text) ;
    String date         = dateController.text ;

    if(amount <= 0){
      commonUtil.showSnakBar(context: context, msg: "Amount bust be greater than 0", error: true) ;
      return false ;
    }

    int quickExpenseId = widget.expenseData == null ? 0 : widget.expenseData?['expense_id'] ;

    bool status = await expenseController.saveQuickExpense(context, amount, name, description, date, cardValue, quickExpenseId) ;

    if(!context.mounted) return ;
    if(status){

      if(quickExpenseId == 0){
        nameController.text = "" ;
        dateController.text = "" ;
        descriptionController.text = "" ;
        amountController.text = "" ;
        cardValue = "0" ;
      }
      
      commonUtil.showSnakBar(context: context, msg: "Quick expense saved", error: false) ;

      setState(() {});
    }


  }

	Widget gap(double height) => Padding(padding: EdgeInsets.only(bottom: height)) ;
}