import 'package:budget_tracker/utils/common.dart';
import 'package:flutter/material.dart';

import '../../widgets/chart/circularChart.dart';
import '../../utils/constant.dart';

class CategoryList extends StatelessWidget{
  final Map category ;
  final String countryCode ;
  final void Function(int budgetDetailId, Map category) categoryClicked;
  final void Function(Map category) addExpenseClicked;
  CategoryList({super.key,  required this.countryCode, required this.categoryClicked, required this.category, required this.addExpenseClicked});

  final CommonUtil commonUtil = CommonUtil() ;

  @override
  Widget build(BuildContext context){
    String name           = category['category_name'];
    double totalAmount    = category['total_amount'] ;
    double spentAmount    = category['amount_spend'] ;
    // int categoryId        = category['category_id'] ;
    int budgetDetailId    = category['budget_details_id'] ;

    double balanceAmount  = totalAmount - spentAmount ;
    bool exeedStatus      = false ;

    if(balanceAmount < 0){
      exeedStatus = true ;
      balanceAmount = spentAmount - totalAmount ;
    }

    double perc = (spentAmount / totalAmount) * 100 ;

    return InkWell(
      onTap: () => categoryClicked(budgetDetailId, category),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.withOpacity(0.18)
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: primaryColor
                      ),
                      child: Center(
                        child: Text(name.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 10), child: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, overflow: TextOverflow.ellipsis),),)
                  ],
                ),
                AddCategoryButton(
                  action: () => addExpenseClicked(category),
                )
              ],
            ),
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                commonUtil.amountAndLabel(label: "Spent", code: countryCode, amount: spentAmount, size: 13, color: Colors.black, lableColor: const Color.fromARGB(255, 101, 101, 101)),
                commonUtil.amountAndLabel(
                  label: exeedStatus ? "Exceeded" : "Limit left", 
                  code: countryCode,
                  amount: balanceAmount, 
                  size: 13, 
                  color: exeedStatus ? Colors.red : Colors.black, 
                  lableColor: exeedStatus ? Colors.red : const Color.fromARGB(255, 101, 101, 101)
                  ),
                commonUtil.amountAndLabel(label: "Total amount", code: countryCode, amount: totalAmount, size: 13, color: Colors.black, lableColor: const Color.fromARGB(255, 101, 101, 101)),
                Transform.scale(
                  scale: 0.85,
                  child: CircularChart(value: spentAmount / totalAmount, perc: perc.toInt().toString(), textColor: exeedStatus ? Colors.red : Colors.black , color: exeedStatus ? Colors.red : primaryColor.withOpacity(0.7), backgroundColor: const Color.fromARGB(255, 193, 193, 193),),
                )
              ],
            ),
          ],
        ),
      ),
    ) ;
  }
}


class AddCategoryButton extends StatelessWidget{
  final void Function() action ;
  const AddCategoryButton({super.key, required this.action});

  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 25,
      child: TextButton(
        onPressed: action, 
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          elevation: 0,
          padding: EdgeInsets.zero
        ),
        child: const Row(
          children: [
            Icon(Icons.add, size: 14,),
            Text("Add expense", style: TextStyle(fontSize: 13),)
          ],
        )
      ),
    ) ;
  }
} 