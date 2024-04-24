
// import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/common.dart';
import '../../db_helper/database.dart';

class BudgetController{
  final CommonUtil commonUtil = CommonUtil() ;


    (double, double) calCategoryAmount(dynamic budget, List<Map<String, dynamic>> categories){
    if(commonUtil.inputAmountValidator(budget) == null){
      double totalAmount  = double.parse(budget.toString()) ;
      double spend        = 0 ;

      for (var element in categories) {
          spend += element['amount'] ;
      }

      return ( totalAmount - spend, spend ) ;
    }

    return (0.0, 0.0) ;
  }


  Future<dynamic> saveBudget(Map<String, dynamic> budgetDetails) async {
    Database db = await Sql.db() ;

    DateTime startDate  = commonUtil.getStartEndDate(budgetDetails['start_date'], "start") ;
    DateTime endDate    = commonUtil.getStartEndDate(budgetDetails['end_date'], "end") ;

    List categories = budgetDetails['category'] ;

    await db.transaction((txn) async {      
      int budgetId = await txn.insert('budget', {
        'budget_name' : budgetDetails['budget_name'],
        'start_date' : commonUtil.datetimeToSting(startDate),
        'end_date' : commonUtil.datetimeToSting(endDate),
        'total_amount' : budgetDetails['budget_amount'],
        'status' : 1
      }) ;

      await saveCategory(txn, budgetId, categories) ;
      
    }) ;
  }

  Future<void> saveCategory(txn, int budgetId, List categories) async {
      for (var element in categories) {
        int categoryId = 0 ;
        if(element['type'] == "new"){
          categoryId = await txn.insert('categories', {
            'category_name' : element['name'],
            'status' : 1
          }) ;

          await txn.insert('budget_details', {
            'budget_id' : budgetId,
            'category_id' : categoryId,
            'total_amount' : element['amount'],
            'amount_spend' : 0,
            'status' : 1
          }) ;
        }

      }
  }

  Future<bool> saveEditedCategory(int budgetId, List<Map<String, dynamic>> categories) async {
    try{
      Database db = await Sql.db() ;

      await db.transaction((txn) async {
          await saveCategory(txn, budgetId, categories) ;
      }) ;

      return true ;
    }catch(e){
      print(e) ;
      return false ;
    }
  }

}