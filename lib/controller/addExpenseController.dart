import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database.dart';
import '../utils/common.dart';

class AddExpenseController {
  final CommonUtil commonUtil = CommonUtil() ;


  Future<bool> saveNewBudgetExpense(BuildContext context, double amount, dynamic description, String date, String card, int categoryId, int budgetDetailId) async {
    try{
      Database db = await Sql.db() ;

      String spendDate = date ;
      if(date.isNotEmpty){
        if(date.length <= 11){
          spendDate = "${date.trim()} 00:00:00" ;
        }
      } else {
        spendDate = commonUtil.datetimeToSting(DateTime.now()) ;
      }

      await db.transaction((txn) async {
        await txn.insert('expense', 
        {
          'description'       : description,
          'amount'            : amount,
          'category_id'       : categoryId,
          'budget_details_id' : budgetDetailId,
          'quick_expense'     : 0,
          'date'              : spendDate,
          'card_id'           : card == "0" ? null : card,
          'status'            : 1
        }
        ) ;

        await txn.rawQuery("""
          UPDATE budget_details SET amount_spend = amount_spend + $amount WHERE id = $budgetDetailId
        """) ;
      }) ;


      return true ;

    }catch(e){
      // ignore: use_build_context_synchronously
      commonUtil.showSnakBar(context: context, error: true, msg: e.toString()) ;
      return false ;
    }
  }

  Future<dynamic> editBudgetExpense(BuildContext context, double amount, dynamic description, String date, String card, int categoryId, int budgetDetailId, double oldAmount, int expenseId) async {
    try{
      Database db = await Sql.db() ;

      String spendDate = date ;
      if(date.isNotEmpty){
        if(date.length <= 11){
          spendDate = "${date.trim()} 00:00:00" ;
        }
      } else {
        spendDate = commonUtil.datetimeToSting(DateTime.now()) ;
      }

      double diff = amount - oldAmount ;

      await db.transaction((txn) async {
        await txn.update('expense', 
        {
          'description'       : description,
          'amount'            : amount,
          'category_id'       : categoryId,
          'budget_details_id' : budgetDetailId,
          'date'              : spendDate,
          'card_id'           : card == "0" ? null : card,
        },
        where: "id = ?",
        whereArgs: [expenseId]
        ) ;

        await txn.rawQuery(""" 
          UPDATE budget_details SET amount_spend = amount_spend + $diff WHERE id =$budgetDetailId
        """) ;
      }) ;

      db.close() ;

      


      return diff ;
    }catch(e){
      // ignore: use_build_context_synchronously
      commonUtil.showSnakBar(context: context, error: true, msg: e.toString()) ;
      return false ;
    }
  }


  Future<List> getCategoryData(BuildContext context, int budgetDetailId) async {
    List categoryData = [] ;

    try{
      Database db   = await Sql.db() ;
      categoryData  = await db.query('budget_details', columns: ['total_amount', 'amount_spend'], where: "id = ?", whereArgs: [budgetDetailId]) ;
    }catch(e){
      // ignore: use_build_context_synchronously
      commonUtil.showSnakBar(context: context, error: true, msg: e.toString()) ;
    }


    return categoryData ;
  }


}