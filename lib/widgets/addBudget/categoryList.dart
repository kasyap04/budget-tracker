import 'package:flutter/material.dart' ;

import '../../utils/constant.dart';
import '../../utils/common.dart';

class CategoryList extends StatelessWidget{
  final List<Map<String, dynamic>> categories ;
  final String currencyCode ;
  final void Function(int index) removeAction ;
  CategoryList({super.key, required this.categories, required this.currencyCode, required this.removeAction});

  final CommonUtil commonUtil = CommonUtil() ;

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;
    double childWidth = (size.width / 2) - 30 ;

    List<Widget> children = <Widget>[] ;

    int index = 0 ;
    for (var element in categories) {
      children.add(CategoryChild(
          width: childWidth,
          amount: commonUtil.formatAmount(double.parse(element['amount'].toString()), currencyCode),
          name: element['name'],
          index : index,
          removeAction: (index) => removeAction(index),
          showRemoveIcon: element['type'] == "new",
        )) ;
        index += 1;
    }

    return Wrap(
      children: children.isNotEmpty ? children : [
        const Padding(padding: EdgeInsets.only(top: 10, bottom: 10), child: Text("No category to show", style: TextStyle(color: Color.fromARGB(255, 72, 72, 72)),),)
      ],
    ) ;
  }
}




class CategoryChild extends StatelessWidget{
  final double width ;
  final String name ;
  final String amount ;
  final int index;
  final bool showRemoveIcon ;
  final void Function(int index) removeAction ;
  const CategoryChild({super.key, required this.width, required this.name, required this.amount, required this.removeAction, required this.index, required this.showRemoveIcon});

  @override
  Widget build(BuildContext context){
    return Container(
      width: width,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showRemoveIcon ? 
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
            onPressed  : () => removeAction(index), 
            constraints: const BoxConstraints(
              maxHeight: 20,
            ),
            icon: const Icon(Icons.close, color: Colors.white),
             padding: EdgeInsets.zero,
             style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              fixedSize: const Size(10, 10),
            )
             ),
          ) 
          :
          const Padding(padding: EdgeInsets.only(top: 20)),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.currency_rupee, color: Colors.white, size: 15,),
                  Text(amount, style: const TextStyle(color: Colors.white, fontSize: 16),)
                ],
              ),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 13))
            ],
          ),
          const Padding(padding: EdgeInsets.only(bottom: 20))
        ],
      ),
    ) ;
  }
}