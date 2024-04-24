import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database.dart';
import '../utils/common.dart';
import '../utils/apiService.dart';

class ProfileController {
  final CommonUtil commonUtil = CommonUtil() ;

	Future<Map> getPersonalDetails(BuildContext context) async {
    Map<String, dynamic> apiData = {} ;
    try{
      Database db = await Sql.db() ;

      List expenseData = await db.query('categories') ;
      apiData['expense_status'] =  expenseData.isNotEmpty ;
      

      List userData = await db.query('settings', columns: ['user_id'] , limit: 1) ;
      int userId = userData[0]['user_id'] ;
      
      String path = "userdata" ;
      Map<String, dynamic> body = {
        'user_id' : userId.toString()
      } ;

      dynamic data = await postAPI(path, body) ;
      
      if(!context.mounted) return {};

      if(data['status']){
        if(data['msg'].isNotEmpty){
            apiData['username'] = data['msg']['user_name'] ;
            apiData['password'] = data['msg']['password'] ;
            apiData['email']    = data['msg']['email'] ;
            apiData['userId']   = userId ;

        }
      } else {
        commonUtil.showSnakBar(context: context, msg: data['msg'], error: true ) ;
      }

    }catch(e){
      commonUtil.commonError(context) ;
    }

    return apiData ;
	}

  Future<bool> changeCurrencyIcon(String currencyIcon) async {
    try{
      Database db = await Sql.db() ;

      await db.update('settings', {
        'currency_icon' : currencyIcon
      }) ;

      return true ;
    }catch(e){
      return false ;
    }
  }

  Future<List> getAllCards() async {
    List cards = [] ;
    try{
      Database db = await Sql.db() ;
      cards = await db.query('cards') ;
    }catch(e){}

    return cards ;
  }

  Future<void> saveNewCard(BuildContext context, String cardName) async {
    try{
      Database db = await Sql.db() ;

      List cardQry = await db.query('cards', where: "card_name = ?", whereArgs: [cardName]) ;

      if(!context.mounted) return ;
      if(cardQry.isNotEmpty){
        commonUtil.showSnakBar(context: context, msg: "This card name already added", error: true) ;
        return ;
      }

      await db.insert('cards', {
        'card_name' : cardName.trim(),
        'status' : 1
      }) ;

      if(!context.mounted) return ;
      commonUtil.showSnakBar(context: context, msg: "Created new card", error: false) ;
    }catch(e){
      commonUtil.commonError(context) ;
    }
  }

  Future<void> editCard(BuildContext context, String cardName, int cardId) async {
    try{
      Database db = await Sql.db() ;

      await db.update('cards', {
        'card_name' : cardName
      }, where: "id = ?", whereArgs: [cardId]) ;

      if(!context.mounted) return ;
      commonUtil.showSnakBar(context: context, msg: "Card name changed", error: false) ;
    }catch(e){
      commonUtil.commonError(context) ;
    }
  }

  Future<void> deleteCard(BuildContext context, int cardId) async {
    try{
      Database db = await Sql.db() ;

      await db.delete('cards', where: "id = ?", whereArgs: [cardId]) ;

      if(!context.mounted) return ;
      commonUtil.showSnakBar(context: context, msg: "Card deleted", error: false) ;
    }catch(e){
      commonUtil.commonError(context) ;
    }
  } 

  Future<void> cardStatusToggle(BuildContext context, int cardId, bool status) async {
    try{
      Database db = await Sql.db() ;

      await db.update('cards', {
        'status' : status 
      }, where: "id = ?", whereArgs: [cardId]) ;

      if(!context.mounted) return ;
      commonUtil.showSnakBar(context: context, msg: "Card active status changed", error: false) ;
    }catch(e){
      commonUtil.commonError(context) ;
    }
  }

  Future<bool> saveUser(BuildContext context, Map<String, dynamic> data) async {
    try{
      dynamic apiData = await postAPI("save-user", data) ;

       if(!context.mounted) return false ;
        commonUtil.showSnakBar(context: context, msg: apiData['msg'], error: !apiData['status']) ;
      return apiData['status'] ; 
    }catch(e){
      commonUtil.commonError(context) ;
      return false ;
    }
  }

  Future<bool> logoutApp() async {
    try{
      Database db = await Sql.db() ;

      await db.update('settings', {'user_id' : null}) ;

      return true ;
    }catch(e){
      return false ;
    }
  }


  Future<bool> backup(BuildContext context, int userId) async {
    try{
      Database db = await Sql.db() ;

      List cards            = await db.query('cards') ;
      List budget           = await db.query('budget') ;
      List categories       = await db.query('categories') ;
      List expense          = await db.query('expense') ;
      List budgetDetails   = await db.query('budget_details') ;

      String path = "backup" ;
      Map<String, dynamic> body = {
        'cards' : jsonEncode(cards),
        'budget' : jsonEncode(budget),
        'categories' : jsonEncode(categories),
        'expense' : jsonEncode(expense),
        'budget_details' : jsonEncode(budgetDetails),
        'user_id' : userId.toString()
      } ;


      dynamic response = await postAPI(path, body) ;

      if(!context.mounted) return false ;

      commonUtil.showSnakBar(context: context, error: !response['status'], msg: response['msg']) ;

      return true ;
    }catch(e){
      commonUtil.commonError(context) ;
      return false ;
    }
  } 


  Future<bool> restore(BuildContext context, int userId) async {
    try{
        String path = "restore" ;
        Map<String, dynamic> body = {
          'user_id' : userId.toString()
        } ;

        dynamic response = await postAPI(path, body) ;

        if(response['status']){
          // response.forEach((key, value) {
          //   print(key);
          // } ) ;

          List cards    = response['cards'] ;
          List budget   = response['budget'] ;
          List categories = response['categories'] ;
          List expense = response['expense'] ;
          List budgetDetails = response['budget_details'] ;

          Database db = await Sql.db() ;
          await db.transaction((txn) async {

            for (var c in cards) {
              await txn.insert('cards', {
                'id' : c['local_id'],
                'card_name' : c['card_name'],
                'status' : c['status']
              }) ;
            }

            for (var b in budget) {
              await txn.insert('budget', {
                'id' : b['local_id'],
                'budget_name' : b['budget_name'],
                'start_date' : b['start_date'].toString().substring(0, 19).replaceAll('T', ' '),
                'end_date' : b['end_date'].toString().substring(0, 19).replaceAll('T', ' '),
                'total_amount' : b['total_amount'],
                'status' : b['status']
              }) ;
            }

            for (var c in categories) {
              await txn.insert('categories', {
                'id' : c['local_id'],
                'category_name' : c['category_name'],
                'status' : c['status']
              }) ;
            }

            for (var e in expense) {
                await txn.insert('expense', {
                  'id' : e['local_id'],
                  'description' : e['description'],
                  'amount' : e['amount'],
                  'category_id' : e['category_id'],
                  'budget_details_id' : e['budgetdetails_id'],
                  'card_id' : e['card_id'],
                  'quick_expense' : e['quick_expense'],
                  'date' : e['date'],
                  'status' : e['status']
                }) ;
            }


            for (var b in budgetDetails) {
                await txn.insert('budget_details', {
                    'id' : b['local_id'],
                    'budget_id' : b['budget_id'],
                    'category_id' : b['category_id'],
                    'total_amount' : b['total_amount'],
                    'amount_spend' : b['amount_spent'],
                    'status' : b['status']
                }) ;
            }


          }) ;

        }
        
      if(!context.mounted) return false ;
      commonUtil.showSnakBar(context: context, error: !response['status'], msg: response['msg']) ;

      return true ;
    }catch(e){
      commonUtil.commonError(context) ;
      return false ;
    }
  }


  Future<List> getSuggestions(int userId) async {
    String path = "get-suggestion" ;
    Map<String, dynamic> body = {
      'user_id' : userId.toString()
    } ;

    dynamic response = await postAPI(path, body) ;

    return response['data'] ;

  } 

}