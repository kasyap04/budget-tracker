import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database.dart';
import '../utils/common.dart';

class BudgetController {
  final CommonUtil commonUtil = CommonUtil() ;

  Future<dynamic> getBudgetDetails(BuildContext context, int budgetId) async {
    try{
      Database db = await Sql.db() ;
      dynamic budgetQuery = await db.rawQuery("""
      SELECT 
        b.budget_name, b.start_date, b.end_date, b.total_amount, SUM(bd.amount_spend) AS spend
      FROM 
        budget AS b
      JOIN
        budget_details AS bd ON bd.budget_id = b.id
      WHERE
        b.id = $budgetId
      GROUP BY b.id
      """) ;


    Map<String, dynamic> budget = {
      ...budgetQuery[0]
    } ;


    
    budget['category']  = await getCategoryDetails(budgetId, db) ;
    budget['cards']     = await db.query('cards', where: "status = ?", whereArgs: [1], columns: ['id', 'card_name']) ;


    return budget ;

    }catch(e){
      if(context.mounted){
        commonUtil.commonError(context) ;
      }
      return [] ;
    }
  }


  Future<dynamic> getCategoryDetails(int budgetId, Database db) async{
      dynamic budgetDetailQuery = await db.rawQuery("""
      SELECT
        c.category_name, bd.total_amount, bd.amount_spend, bd.id AS budget_details_id, bd.category_id AS category_id
      FROM 
        budget_details AS bd
      JOIN
        categories AS c ON bd.category_id = c.id
      WHERE
        bd.budget_id = $budgetId AND bd.status  = 1
    """) ;

    return budgetDetailQuery ;
  }

  dynamic validateBudgetAmount(dynamic value, double spend, BuildContext context){
    dynamic validation = commonUtil.inputAmountValidator(value) ;
    if(validation == null){

      if(double.parse(value) < spend){
        commonUtil.showSnakBar(context: context, msg: "Budget amount must be greater than total spend amount ($spend)", error: true) ;
        return "Invalid amount" ;
      }
    }

    return validation ;
  }


  dynamic validateToDate(dynamic value, dynamic value2){
    dynamic validator1 = commonUtil.inputValidator(value, msg: "Please enter start date") ;
    dynamic validator2 = commonUtil.inputValidator(value2, msg: "Please enter end date") ;

    if(validator1 == null && validator2 == null){
      DateTime fromDate  = commonUtil.strDateToDateTime("$value 00:00:00") ;
      DateTime toDate    = commonUtil.strDateToDateTime("$value2 00:00:00") ;

      int dateDiff = fromDate.difference(toDate).inDays ;

      if(dateDiff < 0){
        return "Please enter valid end date" ;
      }
    }
    return validator2 ;
  }


  Future<bool> saveEditedBudget(int budgetId, Map<String, dynamic> budget) async {
    bool status = false ;

    try{
      Database db = await Sql.db() ;
      await db.update('budget', budget, where: "id = ?", whereArgs: [budgetId]) ;

    status = true ;

    }catch(e){
      status = false ;
    }
    return status ;
  }

  Future<dynamic> getBudgetName(int budgetId) async {
    try{
      Database db = await Sql.db() ;
      dynamic budgetName = await db.query('budget', columns: ['budget_name'], where: "id = ?", whereArgs: [budgetId]) ;
      if(budgetName.isNotEmpty){
        return budgetName[0]['budget_name'] ;
      }
    }catch(e){
      return null ;
    }
    
  }

  dynamic validateCategoryAmount(dynamic value, double oldcategoryAmount, double totalAssigned, double budgetAmount, BuildContext context){
    dynamic validator = commonUtil.inputAmountValidator(value, msg: "Please enter category amount") ;

    if(validator != null) return validator ;

    double amount = double.parse(value) ;
    double diff   = amount - oldcategoryAmount ; 
    
    if(diff + totalAssigned > budgetAmount){
      commonUtil.showSnakBar(context: context, msg: "Total budget amount exceeded by ${ (diff + totalAssigned) - budgetAmount}", error: true) ;
      return "Invalid amount" ; 
    }

  }

  Future<bool> editCategory(int budgetDetailId, int categoryId, String name, double amount) async {
    try{
      Database db = await Sql.db() ;

      await db.update('categories', {'category_name' : name}, where: "id = ?", whereArgs: [categoryId]) ;
      await db.update('budget_details', { 'total_amount' : amount }, where: "id = ?", whereArgs: [budgetDetailId]) ;

      return true ;
    }catch(e){
      return false ;
    }
  }

}