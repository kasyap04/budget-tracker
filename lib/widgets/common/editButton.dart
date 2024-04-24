import 'package:flutter/material.dart';

import '../../utils/constant.dart';


// ignore: must_be_immutable
class EditButton extends StatelessWidget{
  final void Function() action ;
  double fontSize ;
  double iconSize ;
  EditButton({super.key, required this.action, this.fontSize = 14, this.iconSize = 18});

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width ;
    return SizedBox(
      width: (width / 2) - 15,
      height: 30,
      child: TextButton.icon(
        onPressed: action, 
        icon: Icon(Icons.edit, color: primaryColor, size: iconSize), 
        label: Text("Edit", style: TextStyle(fontSize: fontSize, color: primaryColor),)
      ) 
    ) ;
  }
}