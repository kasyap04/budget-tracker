import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


import '../db_helper/database.dart';
import '../utils/common.dart';
import '../controller/budgetController.dart';

class ExpenseHistoryController {
  final CommonUtil commonUtil = CommonUtil() ;
  final BudgetController budgetController = BudgetController() ;


  Future<Map<String, dynamic>> getHistoryPageData(int budgetId, List budgetDetails, dynamic cardId, dynamic months) async {
    try{
      Database db = await Sql.db() ;

        return {
          'history' : await getHistoryData(budgetDetails, cardId, months),
          'category': await budgetController.getCategoryDetails(budgetId, db)
        } ;
    }catch(e){
        return {
          'history' : [],
          'category': []
        } ;
    }
  }

  Future<dynamic> getHistoryData(List budgetDetails, dynamic cardId, dynamic months) async {
    try{
        Database db = await Sql.db() ;

        String cardFiler = "", dateFilter = "" ;

        if(cardId != null){
          if(cardId.isEmpty){
            cardFiler = "AND c.id IS NULL" ;
          } else {
            cardFiler = "AND (c.id IN(${cardId.join(', ')}) OR c.id IS NULL)" ;
          }
        }

        if (months != null) {
        if (months.isEmpty) {
          dateFilter = " AND 1 != 1 ";
        } else {
          dateFilter += "AND (";
          for (var date in months) {
            dateFilter += " strftime('%Y-%m', e.date) = '$date' OR";
          }

          dateFilter = dateFilter.substring(0, dateFilter.length - 2);

          dateFilter += ")";
        }
      }

        // print(dateFilter) ;

        String query = """ 
          SELECT
            e.id, bd.id AS bd_id, e.amount, e.description, ca.category_name, c.card_name, e.date, c.id AS card_id
          FROM
            budget_details AS bd
          JOIN
            categories AS ca ON bd.category_id = ca.id
          JOIN
            expense AS e ON bd.id = e.budget_details_id
          LEFT JOIN 
            cards AS c ON e.card_id = c.id
          WHERE
            bd.id IN(${budgetDetails.join(', ')})
          $cardFiler
          $dateFilter
          ORDER BY
            e.date DESC
        """ ;


      dynamic result = await db.rawQuery(query) ;


      return result ;


    }catch(e){
      return null ;
    }
  }


  Future<Map<String, dynamic>> getSpendCardsAndDates(int budgetId) async {
    List<Map> cards = [] ;
    List<String> months = [] ;
    try{
      Database db = await Sql.db() ;

      cards = await db.rawQuery(""" 
        SELECT
          DISTINCT c.id, c.card_name
        FROM cards AS c
        JOIN
          expense AS e ON  e.card_id = c.id
        JOIN 
          budget_details AS bd ON bd.id = e.budget_details_id
        WHERE 
          bd.budget_id = $budgetId AND c.status = 1
      """) ;

      dynamic dates = await db.rawQuery(""" 
        SELECT
          DISTINCT(strftime('%Y-%m', e.date)) as month 
        FROM
          expense AS e
        JOIN 
          budget_details AS bd ON bd.id = e.budget_details_id
        WHERE
          bd.budget_id = $budgetId
        ORDER BY
          e.date ASC
      """) ;

      for (var element in dates) {
        months.add(element['month']) ;
      }

    }catch(e){
    }

    return {
      'cards' : cards,
      'months' : months
    } ;
  }


  Future<double> deleteExpense(BuildContext context, int expenseId, int budgetDetailId) async {
    double amount = 0 ;
    try{
      Database db = await Sql.db() ;

      await db.transaction((txn) async {
        dynamic amountQuery = await txn.query('expense', columns: ['amount'], where: "id = ?", whereArgs: [expenseId]) ;
        
        if(amountQuery.isNotEmpty){
          amount = amountQuery[0]['amount'] ;
          
          await txn.rawQuery("UPDATE budget_details SET amount_spend = amount_spend - $amount WHERE id = $budgetDetailId") ;
          await txn.delete('expense', where: "id = ?", whereArgs: [expenseId]) ;
        }
      }) ;

      // ignore: use_build_context_synchronously
      commonUtil.showSnakBar(context: context, msg: "Expense deleted", error: false) ;
      return amount ;
    }catch(e){
      // ignore: use_build_context_synchronously
      commonUtil.commonError(context) ;
      return 0 ;
    }
  }

  Future<List<Map>> getBudgetDetails(int expenseId) async {
    try{
      Database db = await Sql.db() ;
      dynamic result = await db.rawQuery(""" 
        SELECT 
          bd.id AS budget_details_id, 
          bd.total_amount AS total_amount,
          bd.amount_spend AS amount_spend,
          bd.category_id AS category_id,
          c.category_name AS category_name
        FROM 
          budget_details AS bd
        JOIN
          expense AS e ON e.budget_details_id = bd.id
        JOIN
          categories AS c ON e.category_id = c.id
        WHERE
          e.id = $expenseId
      """) ;

      return result ;
    }catch(e){
      return [] ;
    }
  }

  Future<List<Map>> getActiveCards() async {
    List<Map> cards = [] ;

    try{
      Database db = await Sql.db() ;

      cards = await db.query(
        'cards',
        columns: ['id', 'card_name'],
        where: "status = ?",
        whereArgs: [1] 
      ) ;

    }catch(e){}

    return cards ;
  }

  Future<bool> deleteCategory(int budgetDetailId) async {
    try{
      Database db = await Sql.db() ;

      await db.transaction((txn) async {
        dynamic budgetDetailQry = await txn.query(
          'budget_details', 
          columns: ['category_id'],
          where: "id = ?",
          whereArgs: [budgetDetailId]
        ) ;

        if(budgetDetailQry.isEmpty){
          throw Error() ;
        }


        int categoryId = budgetDetailQry[0]['category_id'] ;

        txn.delete('categories', where: "id = ?", whereArgs: [categoryId]) ;
        txn.delete('expense', where: "budget_details_id = ?", whereArgs: [budgetDetailId]) ;
        txn.delete('budget_details', where: "id = ?", whereArgs: [budgetDetailId]) ;

      }) ;

      return true ;
    }catch(e){
      return false ;
    }
  }


}