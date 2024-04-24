import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../db_helper/database.dart';
import '../../utils/common.dart';

class HomeController {
  CommonUtil commonUtil = CommonUtil() ;


  Future<bool> getUser() async{
    final db = await Sql.db() ;
    dynamic userQuery = await db.query('settings', columns: ['user_id']) ;

    if(userQuery.isNotEmpty){
      return userQuery[0]['user_id'] != null ;
    }

    return userQuery.isNotEmpty;
  }

  Future<double> getExpenseFromDate(DateTime currentDate) async {
    final db = await Sql.db() ;

    int m         = currentDate.month,
        year      = currentDate.year ;

    String month = m.toString().length == 1 ? "0$m" : m.toString() ;


    String startDate  = "$year-$month-01",
          endDate     = "$year-$month-${commonUtil.getDaysInMonth(m, year)}" ;

    dynamic expenseQuery = await db.query(
      'expense',
      columns: ['SUM(amount) as sum'],
      where: "date >= '$startDate' AND date <= '$endDate' AND quick_expense = 0" 
    ) ;

    double expense = expenseQuery[0]['sum'] ?? 0 ;

    return expense ;
  }


  Future<Map<String, dynamic>> getHomeData() async {
    final db = await Sql.db() ;
    dynamic currencyQuery   = await db.query('settings', columns: ['currency_icon']) ;
    String currency         = currencyQuery[0]['currency_icon'] ;
    double expense          = await getExpenseFromDate(DateTime.now()) ;
    
    int year          = DateTime.now().year;
    String showDate   = "${DateFormat.MMMM().format(DateTime.now())} $year" ;

    String endDate    = "${commonUtil.datetimeToSting(DateTime.now()).substring(0, 10)} 23:59:59" ;
    List budgets      = await getBudgets(endDate: endDate) ;

    return {
      'currency'  : currency,
      'expense'   : expense,
      'showDate'  : showDate,
      'date'      : DateTime.now(),
      'budgets'   : budgets
    } ;

  } 


  Future<Map<String, dynamic>> getPreviousMonthExpense(DateTime currentDate) async {
    var prevMonth = DateTime(currentDate.year, currentDate.month - 1, currentDate.day);

    double expense = await getExpenseFromDate(prevMonth) ;

    String showDate = "${DateFormat.MMMM().format(prevMonth)} ${prevMonth.year}" ;

    return {
      'expense' : expense,
      'showDate'  : showDate,
      'date' : prevMonth
    } ;
  }

  Future<Map<String, dynamic>> getNextMonthExpense(DateTime currentDate) async {
    var prevMonth = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);

    double expense = await getExpenseFromDate(prevMonth) ;

    String showDate = "${DateFormat.MMMM().format(prevMonth)} ${prevMonth.year}" ;

    return {
      'expense' : expense,
      'showDate'  : showDate,
      'date' : prevMonth
    } ;
  }

  Future<List> getBudgets({ String? endDate, String? orderBy}) async {
    Database db = await Sql.db() ;

    String filter = "" ;

    String order = "b.end_date ASC" ;
    if(orderBy != null){
      order = orderBy ;
    }
  

  
    // if(startDate != null){
    //   startDate = startDate.substring(0, 19) ;
    //   filter = " AND b.start_date >= '$startDate'" ;
    // } 

    if(endDate != null){
      endDate = endDate.substring(0, 19) ;
      filter = " AND b.end_date >= '$endDate'" ;
    }

    
    dynamic budget = await db.rawQuery("""
      SELECT 
        b.id, b.budget_name, b.start_date, b.end_date, b.total_amount, SUM(db.amount_spend) AS spend, COUNT(db.id) AS count
      FROM
        budget AS b
      JOIN 
        budget_details AS db ON b.id = db.budget_id
      WHERE
        b.status = 1$filter
      GROUP BY
        b.id
      ORDER BY
        $order
    """) ;

    if(budget.isEmpty){
      return [] ;
    }

    return budget ;

  }

  Future<bool> deleteBudget(int budgetId) async {
	try{
		Database db = await Sql.db() ;
		
		await db.transaction((txn) async {
			List budgetDetailsQry = await txn.query('budget_details', columns: ['id', 'category_id'], where: "budget_id = ?", whereArgs: [budgetId]) ;

			
			if(budgetDetailsQry.isNotEmpty){
				for (var element in budgetDetailsQry) {
					int categoryId 		= element['category_id'] ;
					int budgetDetailId 	= element['id'] ;

					await txn.delete('categories', where: "id = ?", whereArgs: [categoryId]) ;
					await txn.delete('expense', where: "budget_details_id = ?", whereArgs: [budgetDetailId]) ;
					await txn.delete('budget_details', where: "id = ?", whereArgs: [budgetDetailId]) ;
				}

				await txn.delete('budget', where: "id = ?", whereArgs: [budgetId]) ;
			}
		}) ;

		return true ;
	}catch(e){
		return false ;
	}
  }


  Future<List> getCategoryData(int budgetId) async {
     try{
      Database db = await Sql.db() ;

      List category = await db.rawQuery(""" 
      SELECT 
        c.category_name, bd.total_amount, bd.amount_spend, bd.id AS budget_details_id, c.id AS category_id
      FROM 
        budget_details AS bd
      JOIN
        categories AS c ON bd.category_id = c.id
      WHERE
        bd.budget_id = $budgetId
      """) ;

      return category ;
     }catch(e){
      return [] ;
     }
  }

}