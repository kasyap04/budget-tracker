import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/common.dart';
import '../../utils/apiService.dart';
import '../../db_helper/database.dart';

class RegisterLoginController {
  CommonUtil commonUtil = CommonUtil() ;


  Future<void> crearAllData() async {
    try{
      Database db = await Sql.db() ;
      await db.transaction((txn) async {
        txn.delete('cards') ;
        txn.delete('budget') ;
        txn.delete('categories') ;
        txn.delete('expense') ;
        txn.delete('budget_details') ;
      }) ;

    }catch(e){}
  }

  dynamic emailVaidator(dynamic value){
    dynamic defaultValidator = commonUtil.inputValidator(value) ;

    if(defaultValidator != null){
      return defaultValidator ;
    }

    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if(!emailRegExp.hasMatch(value)){
      return 'Please enter valid email' ;
    } else {
      return null ;
    }
  }

  dynamic passwordValidator(dynamic value){
    dynamic defaultValidator = commonUtil.inputValidator(value) ;
    if(defaultValidator != null){
      return defaultValidator ;
    }

    if(value.toString().length < 6){
      return 'Password must have minimun 6 characters' ;
    }
  }

  dynamic password2Validator(dynamic value, TextEditingController controller){
    dynamic defaultValidator = commonUtil.inputValidator(value) ;
    if(defaultValidator != null){
      return defaultValidator ;
    }

    String password = controller.text ;

    if(password != value){
      return 'Password are not matching' ;
    }

  }

  Future<dynamic> sendOTP(String email) async{

    dynamic response = await postAPI('otp', {'email':email}) ;

    if(response != false){
      if(response['status']){
        return true ;
      }
    }

    return false ;

  }

  Future<void> saveServerUserId(dynamic userId) async{
    Database db = await Sql.db() ;
  
    List settings = await db.query('settings') ;

    if(settings.isEmpty){
      await db.insert('settings', {
        'user_id' : userId,
        'currency_icon' : 'IND'
      }) ;
    } else {
      await db.update('settings', {'user_id' : userId}) ;
    }
  }

  Future<dynamic> register(Map<String, dynamic> regData) async {
    String path = 'login/register' ;

    dynamic response = await postAPI(path, regData) ;
    if(response['status']){
      dynamic userId = response['user_id'] ;
      await saveServerUserId(userId) ;
      return true ;
    }

    return false ;
  }


  Future<dynamic> login(Map<String, dynamic> loginData, BuildContext context) async {
    String path = 'login/' ;

      dynamic response = await postAPI(path, loginData) ;

      print("response = $response") ;

      if(response['status']){
        dynamic userId = response['user_id'] ;
        await saveServerUserId(userId) ;
      }

      if(response['status'] == false && response['method'] == 'snackbar'){
        // ignore: use_build_context_synchronously
        commonUtil.showSnakBar(context: context, error: true, msg: response['msg'] ) ;
      }

      return response ;
  }

  Future<void> sendOTPForResetPassword(BuildContext context, String email) async {
    try{
      String path = "login/forgot-password" ;
      Map<String, dynamic> body = {
        'email' : email
      } ;

      dynamic res = await postAPI(path, body) ;

      if(!context.mounted) return ;
      commonUtil.showSnakBar(context: context, msg: res['msg'], error: !res['status']) ;
    }catch(e){
      commonUtil.showSnakBar(context: context, msg: e.toString(), error: true) ;
    }
  }


  Future<bool> verifyOTP(BuildContext context, String otp, String email) async {
    try{
      String path = "login/verify-top" ;
      Map<String, dynamic> body = {
        'email' : email,
        'otp' : otp
      } ;

      dynamic res = await postAPI(path, body) ;

      if(!context.mounted) return false ;
      commonUtil.showSnakBar(context: context, msg: res['msg'], error: !res['status']) ;
      return res['status'] ;
    }catch(e){
      commonUtil.showSnakBar(context: context, msg: e.toString(), error: true) ;
      return false ;
    }
  }

  Future<bool> changeForgottenPassword(BuildContext context, String password, String email) async {
    try{
      String path = "login/reset-password" ;
      Map<String, dynamic> body = {
        'email' : email,
        'password' : password
      } ;

      dynamic res = await postAPI(path, body) ;
      if(!context.mounted) return false ;
      commonUtil.showSnakBar(context: context, msg: res['msg'], error: !res['status']) ;
      return res['status'] ;
    }catch(e){
      commonUtil.showSnakBar(context: context, msg: e.toString(), error: true) ;
      return false ;
    }
  }


}