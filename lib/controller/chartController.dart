import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database.dart';
import '../utils/common.dart';

class ChartController{
	final CommonUtil commonUtil ;
	ChartController({required this.commonUtil}) ;
	
	Future<Database> getdb() async => await Sql.db() ;


	(DateTime, DateTime) getStartEndDate(String timePeriod, DateTime date) {
		List startEndDates	= commonUtil.getStartEndDateFromTimeFlag(timePeriod, date) ;

		DateTime startDate	= commonUtil.strDateToDateTime(startEndDates[0].toString()) ;
		DateTime endDate   	= commonUtil.strDateToDateTime(startEndDates[1].toString()) ;

		return (startDate, endDate) ;
	}

	List<String> changeToStrictWeek(List dates, DateTime date){
		int daysInMonth 	= commonUtil.getDaysInMonth(date.month, date.year) ;
		DateTime startDate 	= commonUtil.strDateToDateTime(dates[0]) ;
		DateTime endDate 	= commonUtil.strDateToDateTime(dates[1]) ;

		if(startDate.month != date.month) {
			startDate = DateTime(date.year, date.month, 1) ;
		}

		if(endDate.month != date.month) {
			endDate = DateTime(date.year, date.month, daysInMonth) ;
		}

		return [
			commonUtil.datetimeToSting(startDate),
			commonUtil.datetimeToSting(endDate)
		] ;
	}

	Future<Map<String, dynamic>> changeDropDown(dynamic timePeriod, DateTime date, int expenseType) async {
		List<Map<String, dynamic>> expenseChart = [] ;
		double maxAmount = 0, totalExpense = 0 ;

		final startEndDate 	= getStartEndDate(timePeriod, date) ;
		String startDate 	= commonUtil.datetimeToSting(startEndDate.$1) ;
		String endDate 		= commonUtil.datetimeToSting(startEndDate.$2) ;
		

		switch(timePeriod){
			case 'weekly':

				List expense	= await getTimePeriodExpense(startDate, endDate, timePeriod, expenseType) ;
				
				for(String weekName in commonUtil.weeks){
					expenseChart.add({
						'date' : weekName,
						'amount' : 0.0
					}) ;
				}
				for(var exp in expense){
					int weekIndex = int.parse(exp['date']) ;
					expenseChart[weekIndex]['amount'] = exp['amount'] ;

					totalExpense += exp['amount'] ;
					if(exp['amount'] > maxAmount){
						maxAmount = exp['amount'] ;
					}
				}

				break ;
			
			case 'monthly':
				int month = date.month, changableWeek = 1 ;
				DateTime monthWeek = DateTime(date.year, date.month, changableWeek) ;
				int weekCount = 1 ;

				while(month == monthWeek.month) {
					List dateSE = commonUtil.getStartEndDateFromTimeFlag('weekly', monthWeek) ;
					dateSE = changeToStrictWeek(dateSE, monthWeek) ;
					
					String startDate = dateSE[0], endDate = dateSE[1] ;
					List expense	= await getTimePeriodExpense(startDate, endDate, timePeriod, expenseType) ;
					
					double amount = 0 ;
					if(expense.isNotEmpty){
						amount = expense[0]['amount'] ;
					}

					expenseChart.add({
						'date' : "WEEK $weekCount",
						'amount' : amount
					}) ;

					if(amount > maxAmount){
						maxAmount = amount ;
					}

					totalExpense += amount ;

					changableWeek += 7 ;
					monthWeek = DateTime(date.year, date.month, changableWeek) ;
					weekCount ++ ;
				}
				
				break ;

			case 'yearly':
				int monthStart = 1 ;
				DateTime changableMonth = DateTime(date.year, monthStart, 1) ;
				
				while(date.year == changableMonth.year) {
					List dateSE = commonUtil.getStartEndDateFromTimeFlag('monthly', changableMonth) ;
					String startDate = dateSE[0], endDate = dateSE[1] ;
					
					String monthName = DateFormat('MMM').format(changableMonth) ;

					List expense	= await getTimePeriodExpense(startDate, endDate, timePeriod, expenseType) ;
					
					double amount = 0 ;
					if(expense.isNotEmpty){
						amount = expense[0]['amount'] ;
					}

					expenseChart.add({
						'date' : monthName,
						'amount' : amount
					}) ;

					if(amount > maxAmount){
						maxAmount = amount ;
					}

					totalExpense += amount ;

					monthStart += 1 ;
					changableMonth = DateTime(date.year, monthStart, 1) ;	
				}

				break ;

		}

		return {
			'chart' : expenseChart,
			'max' : maxAmount,
			'sum' : totalExpense,
			'displayDate' : changeDatePeriod(timePeriod, date, null).$2 
		} ;
	}

	
	Future<List> getTimePeriodExpense(String startDate, String endDate, String timePeriod, int expenseType) async {  // expenseType :  0 = only budgeted ;  1 = only quick expense ;  2 = both 	
		String groupBy = "strftime('%Y-%m', date)";
		String select = "" ;
		String type = "" ;
		
		if(timePeriod == 'weekly'){
			groupBy = "strftime('%d', date)" ;
			select = ", strftime('%w', date) AS date" ;
		}

		if(expenseType == 0 || expenseType == 1){
			type = " AND quick_expense = $expenseType" ;
		}

		try{
			Database db = await getdb() ;
			
			dynamic expense = await db.rawQuery(""" 
				SELECT 
					SUM(amount) AS amount$select
				FROM 
					expense 
				WHERE
					date >= '$startDate' AND date <= '$endDate' AND status = 1 $type
				GROUP BY
					$groupBy
				ORDER BY
					date ASC
			""") ;

			return expense ;

		}catch(e){
			return [] ;
		}
		
	}

	(DateTime, String) changeDatePeriod(String timePeriod, DateTime currentTime, dynamic forward) {
		String timeFormat 	= "";
		int dateChanger 	= 0 ;
		DateTime newDate 	= currentTime ;


		if(forward != null){
			switch(timePeriod){
				case 'weekly' :
					dateChanger = 7 ;
					break ;

				case 'monthly' :
					dateChanger = commonUtil.getDaysInMonth(currentTime.month, currentTime.year) ;
					break ;
				
				case 'yearly':
					dateChanger = commonUtil.getDaysInYear(currentTime.year) ;
					break ;
			}

			newDate = forward ?
				DateTime(currentTime.year, currentTime.month, currentTime.day + dateChanger) :
				DateTime(currentTime.year, currentTime.month, currentTime.day - dateChanger) ;
		}


		final startEndDate 	= getStartEndDate(timePeriod, newDate) ;
		DateTime startDate 	= startEndDate.$1 ;
		DateTime endDate 	= startEndDate.$2 ;		
		timeFormat 			= "${DateFormat('d MMM yy').format(startDate)} - ${DateFormat('d MMM yy').format(endDate)}" ;

		return (newDate, timeFormat) ;
	}

}