
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database.dart';
import '../utils/common.dart';

class QuickExpenseController {

	final CommonUtil commonUtil = CommonUtil() ;


  Future<Map> getQuickExpenseData(int? limit) async {
    try{
      Database db = await Sql.db() ;

      List cardQry    = await db.query('cards', columns: ['id', 'card_name'], where: "status = ?", whereArgs: [1]) ;
      List<Map> cards = [] ;
      
      for (var c in cardQry) {
          cards.add({
            'id' : c['id'],
            'card_name' : c['card_name']
          }) ;
      }
	  
      return {
        'cards' : cards,
        'history' : await getQuickExpenseHistory(null, limit)
      } ;
    }catch(e){
        return {} ;
    }
  }

  Future<List> getQuickExpenseHistory(dynamic cardId, int? limit) async {
	try{
		Database db = await Sql.db() ;

        String cardFiler = "", limitFilter = "" ;

        if(cardId != null){
          if(cardId.isEmpty){
            cardFiler = "AND c.id IS NULL" ;
          } else {
            cardFiler = "AND (c.id IN(${cardId.join(', ')}) OR c.id IS NULL)" ;
          }
        }

    if(limit != null){
      limitFilter = "LIMIT $limit" ;
    }

		List history = await db.rawQuery(""" 
    SELECT
      e.id, e.amount, 0 AS bd_id, e.description, ca.category_name, c.card_name, e.date, c.id AS card_id
    FROM
      expense AS e
    JOIN
      categories AS ca ON e.category_id = ca.id
    LEFT JOIN 
      cards AS c ON e.card_id = c.id
		WHERE
			quick_expense = 1 $cardFiler
    ORDER BY
      e.date DESC
    $limitFilter
        """) ;

		return history ;

	}catch(e){
		return [] ;
	}
  }


	Future<bool> saveQuickExpense(BuildContext context, double amount, dynamic name, dynamic description, String date, String card, int? quickExpenseId) async {
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

      if(quickExpenseId == 0) {
        await db.transaction((txn) async {
          int categoryId = await txn.insert('categories', {
            'category_name' : name.toString().trim(),
            'status' : 1
          }) ;

          await txn.insert('expense', 
          {
          'description'       : description,
          'amount'            : amount,
          'category_id'       : categoryId,
          'quick_expense'     : 1,
          'date'              : spendDate,
          'card_id'           : card == "0" ? null : card,
          'status'            : 1
          }
          ) ;
        }) ;
      } else {

          int categoryId = await getCategoryId(db, quickExpenseId ?? 0);
          
          if(categoryId != 0){

            await db.transaction((txn) async {
              await txn.update('categories', 
              {
                'category_name' : name.toString().trim()
              },
              where: "id = ?",
              whereArgs: [categoryId]
              ) ;

              await txn.update('expense', 
              {
              'description'       : description,
              'amount'            : amount,
              'category_id'       : categoryId,
              'quick_expense'     : 1,
              'date'              : spendDate,
              'card_id'           : card == "0" ? null : card,
              },
              where: "id = ?",
              whereArgs: [quickExpenseId]
              ) ;

            }) ;

          }

      }


			return true ;
		} catch(e){
			if(context.mounted){
				commonUtil.showSnakBar(context: context, msg: e.toString(), error: true) ;
			}
			return false ;
		}
	}

  Future<int> getCategoryId(Database db, int expenseId) async {
    dynamic categoryIdQry = await db.query('expense', columns: ['category_id'], where: "id = ?", whereArgs: [expenseId]) ;
    if(categoryIdQry.isNotEmpty){
      return categoryIdQry[0]['category_id'] ;
    } 

    return 0 ;
  }

  Future<bool> deleteExpense(int expenseId) async {
    try{
      Database db = await Sql.db() ;
      int categoryId = await getCategoryId(db, expenseId) ;
      
      await db.transaction((txn) async {
        await txn.delete('categories', where: "id = ?", whereArgs: [categoryId]) ;
        await txn.delete('expense', where: "id = ?", whereArgs: [expenseId]) ;
      }) ;

      return true ;
    }catch(e){
      return false ;
    }
  }
	
}