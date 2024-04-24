import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CommonUtil { 
  List<String> get weeks => ['SUN', 'MON', 'TUE', 'WED', 'THE', 'FRI', 'SAT'] ;
  
  int getDaysInMonth(int month, int year) {
    if (month == DateTime.february) {
      final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  int getDaysInYear(int year){
    int days = 0 ;
    for(int i = 1; i <= 12; i++){
        days += getDaysInMonth(i, year) ;
    }
    return days ;
  }

  String formatAmount(double amount, String code) {
    String local = 'en_in' ;
    if(code != 'IND'){
      local = 'en_us' ;
    }

    NumberFormat formater = NumberFormat.decimalPattern(local) ;
    
    return formater.format(amount).toString() ;
  }


  IconData currencyIcon(String code) {
    late IconData icon ;
    switch(code){
      case 'IND':
        icon = Icons.currency_rupee ;
        break ;

      case 'USD' :
        icon = Icons.attach_money;
        break;

      case 'YEN':
        icon = Icons.currency_yen ;
        break ;

      case 'EUR':
        icon = Icons.euro ;
        break ;

      case 'FRA':
        icon = Icons.currency_franc;
        break ;

      case 'DEF':
        icon = Icons.money ;
        break ;

      case 'POU':
        icon = Icons.currency_pound ;
        break ;

      case 'BIT':
        icon = Icons.currency_bitcoin ;
        break ;

      default :
      icon = Icons.currency_rupee ;
    }

    return icon ;
  }


    dynamic inputAmountValidator(dynamic value, {dynamic msg}) {
    if (value == null || value.isEmpty) {
      return msg ?? 'Please enter an amount';
    } else if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Please enther valid amount';
    } else {
      return null;
    }
  }

  dynamic inputValidator(dynamic value, {dynamic msg} ){
    if (value == null || value.isEmpty) {
        return msg ?? 'Please enter this field' ;
    } else {
      return null;
    }
  }

  void showSnakBar({required BuildContext context, required String msg, required bool error} ){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(
          color: error ? Colors.red : Colors.black,
          fontSize: 16
        ),),
        backgroundColor: const Color.fromARGB(255, 252, 236, 255),
        elevation: 100,
      )
    ) ;
  }

  void commonError(BuildContext context) => showSnakBar(context: context, msg: "Something wend wrong, Please try again later", error: true) ;


  DateTime getStartEndDate(DateTime date, String type){   // type = end, start
    String strDate = DateFormat("yyy-MM-dd").format(date) ;

    if(type == "end"){
        strDate = "$strDate 23:23:59" ;
    } else {
        strDate = "$strDate 00:00:00" ;
    }

    return DateFormat("yyy-MM-dd HH:mm:ss").parse(strDate) ;
  }

  String datetimeToSting(DateTime date) => DateFormat("yyy-MM-dd HH:mm:ss").format(date) ;


  List getStartEndDateFromTimeFlag(String time, DateTime date) {
    var start_date, end_date;
    
    if (time == "today") {
      String today  = DateFormat("yyy-MM-dd").format(date);
      start_date    = "$today 00:00:00";
      end_date      = "$today 23:59:59";

    } else if (time == "weekly" || time == "monthly" || time == "yearly") {
      if (time == "weekly") {
        var weekday = date.weekday == 7 ? 0 : date.weekday;
        start_date  = date.subtract(Duration(days: weekday));
        end_date    = date.add(Duration(days: DateTime.daysPerWeek - weekday - 1));
        start_date  = DateTime(start_date.year, start_date.month, start_date.day).toString();
        end_date    = DateTime(end_date.year, end_date.month, end_date.day).toString();
      } else if (time == "monthly") {
        start_date  = DateTime(date.year, date.month, 1).toString();
        end_date    = DateTime(date.year, date.month + 1, 0).toString();
      } else if(time == 'yearly'){
        start_date  = DateTime(date.year, 1, 1).toString();
        end_date    = DateTime(date.year, 12, 31).toString();
      }
      end_date = "${end_date.substring(0, 10)} 23:59:59";
    }

    return [start_date, end_date];
  }

  DateTime strDateToDateTime(String date) => DateFormat("yyy-MM-dd HH:mm:ss").parse(date.trim().length == 10 ? "$date 00:00:00" : date) ; 

  String dateTimePrettyFormat(DateTime date) => DateFormat("MMM dd, yyyy").format(date) ;

  String intToMonthName(int month) => DateFormat('MMMM').format(DateTime(0, month)) ;

  Widget displayAmount({required double amount, required String code, required double size, required Color color, required bool bold}){
    return Row(
      children: [
        Icon(currencyIcon(code), size: size - 2, color: color,),
        Text(formatAmount(amount, code), style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.bold : null))
      ],
    ) ;
  }

  Widget amountAndLabel({required String label, required String code, required double amount, required double size, required Color color, required Color lableColor}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(currencyIcon(code), size: size - 2, color : color),
            Text(formatAmount(amount, code), style: TextStyle(fontSize: size, color: color),)
          ],
        ),
        Text(label, style: TextStyle(color: lableColor, fontSize: size - 1),)
      ],
    ) ;
  }

}