import 'package:flutter/material.dart';

import '../../utils/constant.dart';
import '../../utils/common.dart';
import '../../controller/profileController.dart';

class CurrencyIcon extends StatefulWidget{
  final String currencyCode ;
  const CurrencyIcon({super.key, required this.currencyCode});

  @override
  State<CurrencyIcon> createState() => CurrencyIconState() ;
}


class CurrencyIconState extends State<CurrencyIcon>{
  final CommonUtil commonUtil = CommonUtil() ;
  final ProfileController profileController = ProfileController() ;

  Map<String, String> currencyList = <String, String>{
    'IND' : 'Rupee', 
    'USD' : 'USD', 
    'YEN' : 'Yen', 
    'EUR' : 'Euro',
    'FRA' : 'Franc',
    'POU' : 'Pound',
    'BIT' : 'Bitcoint',
    'DEF' : 'Money'
 } ;

String currencyIcon = "" ;
 @override
 void initState(){
  super.initState();
  currencyIcon = widget.currencyCode ;
 }

  @override
  Widget build(BuildContext context){
    List<Widget> children = <Widget>[] ;

    currencyList.forEach((key, value) {
      children.add(
        Currency(
          gap: (height) => gap(height),
          icon: commonUtil.currencyIcon(key),
          name: value,
          selected: currencyIcon == key,
          currencyCode: key,
          onTap: (code) => changeIcon(context, code),
        )
      ) ;
    }) ;

    return Center(
      child: Wrap(
        children: children,
      ),
    );
  }

  Widget gap(double height) => Padding(padding: EdgeInsets.only(top: height)) ;

  void changeIcon(BuildContext context, String iconString) async {
    bool status = await profileController.changeCurrencyIcon(iconString) ;

    if(!context.mounted) return ;
    if(status){
      setState(() {
        currencyIcon = iconString ;
      });
      commonUtil.showSnakBar(context: context, msg: "Currency icon changed", error: false);
    } else {
      commonUtil.commonError(context) ;
    }
    
  }

}


class Currency extends StatelessWidget{
  final bool selected ;
  final IconData icon ;
  final String currencyCode ;
  final String name ;
  final Widget Function(double height) gap ;
  final void Function(String currencyCode) onTap ;
  const Currency({super.key, required this.selected, required this.icon, required this.name, required this.gap, required this.onTap, required this.currencyCode});

  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: () => onTap(currencyCode),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          color: selected ? primaryColor : primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : primaryColor, size: 15),
            gap(5),
            Text(name, style: TextStyle(color: selected ? Colors.white : primaryColor, fontSize: 16),)
          ],
        ),
      ),
    ) ;
  }
}