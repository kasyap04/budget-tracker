import 'package:flutter/material.dart';

import '../../utils/common.dart';
import '../../utils/constant.dart';

class CategoryFilterBox extends StatelessWidget{
  final List category ;
  final String currencyCode ;
  final List<int> selectedCategories ;
  final Map<int, Map<String, dynamic>> selectedCards ;
  final Map<String, bool> selectedMonth ;
  final void Function(int id) categoryTapped ;
  final void Function(int id) cardTapped ;
  final void Function(String id) monthTapped ;
  CategoryFilterBox({super.key, required this.category, required this.currencyCode, required this.categoryTapped, required this.selectedCategories, required this.selectedCards,  required this.cardTapped, required this.selectedMonth, required this.monthTapped});

  final CommonUtil commonUtil =  CommonUtil() ;

  @override
  Widget build(BuildContext context){
   List<Widget> children = <Widget>[] ;

    for (var element in category) {
      children.add(
        CategoryBox(
          name: element['category_name'], 
          total: commonUtil.formatAmount(element['total_amount'], currencyCode), 
          spend: commonUtil.formatAmount(element['amount_spend'], currencyCode), 
          icon: commonUtil.currencyIcon(currencyCode),
          isActive: selectedCategories.contains(element['budget_details_id']),
          budgetDetailId: element['budget_details_id'],
          onTap: (id) => categoryTapped(id),
        )) ;
    }
  


    selectedCards.forEach((key, value) {
      children.add(OtherBox(
          cardId: key,
          name: value['name'],
          isActive: value['active'],
          onTap: (id) => cardTapped(id),
          label: "card",
        )) ;
    }) ;


    selectedMonth.forEach((key, value) {
      children.add(OtherBox(
          cardId: key,
          name: commonUtil.intToMonthName(int.parse(key.substring(5, key.length))),
          isActive: value,
          onTap: (id) => monthTapped(id),
          label: key.substring(0, 4),
        )) ;
    }) ;




    return Center(
      heightFactor: 1.2,
      child: Wrap(
        children: children,
      ),
    ) ;
  }
}


class CategoryBox extends StatelessWidget{
  final String name ;
  final String total;
  final String spend;
  final IconData icon ;
  final bool isActive ;
  final int budgetDetailId ;
  final void Function(int id) onTap ;
  const CategoryBox({super.key, required this.name, required this.total, required this.spend, required this.icon, required this.isActive, required this.onTap, required this.budgetDetailId});

  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: () => onTap(budgetDetailId),
      child: Container(
        width: 170,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.9) : primaryColor.withOpacity(0.16),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
          children: [
            Text(name, style: TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
              color: isActive ? Colors.white : primaryColor
            )),
            const Padding(padding: EdgeInsets.only(bottom: 5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                setIcon(),
                setText("$spend/"),
                setIcon(),
                setText(total)
              ],
            )
          ],
        ),
      ),
    ) ;
  }

  Widget setIcon() => Icon(icon, size: 13, color: isActive ? Colors.white : primaryColor,) ; 
  
  Widget setText(String value) => Text(value, style: TextStyle(
              fontSize: 14,
              overflow: TextOverflow.ellipsis,
              color: isActive ? Colors.white : primaryColor
            )) ;
}

class OtherBox extends StatelessWidget{
  final String name ;
  final bool isActive ;
  final dynamic cardId ;
  final String label ;
  final void Function(dynamic id) onTap ;
  const OtherBox({super.key, required this.name, required this.isActive, required this.onTap, required this.cardId, required this.label});

  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: () => onTap(cardId),
      child: Container(
        width: 170,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.9) : primaryColor.withOpacity(0.16),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
          children: [
            Text(name, style: TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
              color: isActive ? Colors.white : primaryColor
            )),
            const Padding(padding: EdgeInsets.only(bottom: 2)),
            Text(label, style: TextStyle(color: isActive ? Colors.grey : primaryColor),)
          ],
        ),
      ),
    ) ;
  }
}