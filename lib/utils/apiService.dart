import 'dart:convert';

import 'package:http/http.dart' as http;
import 'constant.dart';


class APIService{
  static dynamic header = "" ;
  static void setHeader(dynamic h){
    header = h ;
  }
}

Future<Map> postAPI(String path, Map<String, dynamic> body) async{
  Map<String, dynamic> errorMsg = {
    'status'  : false,
    'msg'     : 'Something went wrong! Please try again later',
    'method'  : 'snackbar'
  } ;

  try{
     dynamic uri        = Uri.parse("$API$path");
     dynamic apiHeader  = APIService.header ;


     if(apiHeader == ""){
        apiHeader = {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        } ;
     } else {
        apiHeader["Content-Type"] = "application/x-www-form-urlencoded" ;
        apiHeader["Accept"] = "application/json" ;
     }


      http.Response response = await http.post(uri,
            headers : apiHeader ,
            body: body
            );

      try{
          response.headers.remove('content-length') ;
          print("response.headers['set-cookie'] = ${response.headers['set-cookie']}") ;
          response.headers['Cookie'] =  response.headers['set-cookie'].toString() ;
      }catch(e){
        // ignore: avoid_print
        print("ERROR => $e") ;
      }
      
      // print("response = ${response.body}") ;


      APIService.setHeader(response.headers);

      if(response.statusCode == 200){
        Map res = jsonDecode(response.body) ;
        res['method'] = "inline" ;

        return res ;

        // return {
        //   'status'  : res['status'],
        //   'msg'     : res['msg'],
        //   'method'  : 'inline'
        // };
      } else {
        return errorMsg ;
      }
  }catch(e){
    print(e) ;
    return errorMsg ;
  }
}