import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../utils/common.dart' ;

class History extends StatelessWidget{
  final List history ;
  final String currencyCode ;
  final void Function(int id, int budgetDetailId) deleteAction ;
  final void Function(Map<String, dynamic> expenseData) editAction ;
  History({super.key, required this.history, required this.currencyCode, required this.deleteAction, required this.editAction});

  final CommonUtil commonUtil = CommonUtil() ; 

  @override
  Widget build(BuildContext context){

    List<Widget> children = <Widget>[] ;

    String lastDate = "" ;
    if(history.isNotEmpty){
      for (var element in history) {
        DateTime t        = DateFormat("HH:mm:ss").parse(element['date'].toString().substring(11, element['date'].length)) ;
        String time       = DateFormat("hh:ss a").format(t) ;
        String date       = element['date'].toString().substring(0, 11);
        String bottomName = "" ;

        if(element['card_name'] != null){
            bottomName = element['card_name'] ;

            if(element['description'].toString().isNotEmpty && element['description'] != null){
              bottomName += " | ${element['description']}" ;
            }
        } else {
            if(element['description'].toString().isNotEmpty && element['description'] != null){
              bottomName = "${element['description']}" ;
            }
        }

        if (lastDate != date) {
          lastDate = date;
          children.add(DateDivision(date: lastDate));
        }

        Map<String, dynamic> expenseData = {
          'expense_id' : element['id'],
          'amount' : element['amount'],
          'date' : element['date'],
          'card' : element['card_id'],
          'description' : element['description'],
          'category_name' : element['category_name']
        } ;

        children.add(
          HistoryRow(
            expenseId: element['id'],
            budgetDetailId: element['bd_id'],
            amount: commonUtil.formatAmount(element['amount'], currencyCode),
            bottomName: bottomName,
            icon: commonUtil.currencyIcon(currencyCode),
            name: element['category_name'],
            time: time,
            expenseData: expenseData,
            delete: (id, budgetDetailId) => deleteAction(id, budgetDetailId),
            edit: (expenseData) => editAction(expenseData),
          )
        ) ;
      }
    } else {
      children.add(
        emptyExpense()
      ) ;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ) ;
  }


  Widget emptyExpense(){
    return const Padding(
      padding: EdgeInsets.only(top: 30),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "No expense to show",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    ) ;
  }


}


class HistoryRow extends StatelessWidget{
  final String name ;
  final String bottomName ;
  final String time ;
  final String amount ;
  final IconData icon ;
  final int expenseId ;
  final int budgetDetailId ;
  final Map<String, dynamic> expenseData ;
  final void Function(int id, int budgetDetailId) delete ;
  final void Function(Map<String, dynamic> expenseData) edit ;
  const HistoryRow({super.key, required this.name, required this.bottomName, required this.time, required this.amount, required this.icon, required this.expenseId, required this.delete, required this.edit, required this.budgetDetailId, required this.expenseData});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Slidable(
          key: UniqueKey(),
          startActionPane: ActionPane(
            motion:  const ScrollMotion(), 
            children:  [
                SlidableAction(
                  onPressed: (context) => delete(expenseId, budgetDetailId),
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                )
            ]
          ),
          endActionPane: ActionPane(
            motion:  const ScrollMotion(), 
            children:  [
                SlidableAction(
                  onPressed: (context) => edit(expenseData),
                  backgroundColor: const Color.fromARGB(255, 31, 130, 163),
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Edit',
                )
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, overflow: TextOverflow.ellipsis)),
                    Row(
                      children: [
                        Icon(icon, size: 17),
                        Text(amount, style: const TextStyle(fontSize: 18))
                      ],
                    )
                  ],
                ),
                const Padding(padding: EdgeInsets.only(bottom: 5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(bottomName, style: const TextStyle(color: Color.fromARGB(255, 105, 105, 105), fontSize: 13, overflow: TextOverflow.ellipsis)),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ) ;
  }
}



class DateDivision extends StatelessWidget{
  final String date ;
  const DateDivision({super.key, required this.date});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(dateFormat(), style: const TextStyle(fontSize: 13)),
    ) ;
  }

  String dateFormat(){
    var d = DateFormat("yyy-MM-DD").parse(date);
    DateTime today = DateTime.now();
    int dateDiff = today.difference(d).inDays;
    
    String dateFormate = date;
    if (dateDiff == 0) {
      dateFormate = "Today";
    } else if (dateDiff == 1) {
      dateFormate = "Yesterday";
    } else {
      dateFormate = "${DateFormat('EEEE').format(d)} - ${DateFormat.yMMMd().format(d)}";
    }

    return dateFormate ;

  }

}