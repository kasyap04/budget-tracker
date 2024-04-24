import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HeaderText extends StatelessWidget{
  final String name ;
  late double? top;
  late double? bottom;
  late double? left;
  late double? right;
  HeaderText({super.key,
  required this.name,
  this.top,
  this.left,
  this.bottom,
  this.right 
  });

  @override
  Widget build(BuildContext context){
    return Padding(padding: EdgeInsets.only(
      top: top ?? 0,
      bottom: bottom ?? 0,
      right: right ?? 0,
      left: left ?? 0
    ), 
    child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ) ;
  }
}