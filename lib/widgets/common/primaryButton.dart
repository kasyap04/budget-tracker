import 'package:flutter/material.dart';

import '../../utils/constant.dart';
// import '../../utils/common.dart';

// ignore: must_be_immutable
class PrimaryButton extends StatelessWidget{
  late double? width ;
  final String buttonName ;
  late double? top ;
  late double? left ;
  late double? right ;
  late double? bottom ;
  final void Function() action ;
  PrimaryButton({super.key, 
  this.width,
   required this.buttonName,
   this.top,
   this.left,
   this.right,
   this.bottom, 
   required this.action});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(
        top: top ?? 0,
        bottom: bottom ?? 0,
        right: right ?? 0,
        left: right ?? 0
      ),
      child: SizedBox(
        width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            elevation: 0,
            padding: const EdgeInsets.all(15)
          ),
          onPressed: action, 
          child: Text(buttonName, style: const TextStyle(fontSize: 20),)
        ),
        ),
    ) ;
  }
}