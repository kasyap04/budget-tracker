import 'dart:async';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DeleteButton extends StatefulWidget{
  final void Function() delete ;
  double fontSize ;
  double iconSize ;
  DeleteButton({super.key, required this.delete, this.fontSize = 14, this.iconSize = 18});

  @override
  State<DeleteButton> createState() => DeleteButtonState() ;
}

class DeleteButtonState extends State<DeleteButton>{

  bool delete = false;

  late var timer;

  @override
  void initState() {
    super.initState();
    timer = null;
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width ;
    return SizedBox(
      width: (width / 2) - 15,
      height: 30,
      child: TextButton.icon(
        onPressed: (){
          setState(() {
            if (!delete) {
              delete = true;
              resetDeleteButton();
            } else {
              widget.delete();
            }
          });
        }, 
        icon: Icon(
          delete ? Icons.done : Icons.delete, 
          color: Colors.red, 
          size: widget.iconSize
        ),
        label: Text(
          delete ? "Confirm" : "Delete", 
          style: TextStyle(color: Colors.red, fontSize: widget.fontSize)),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero
        ),
      ),
    ) ;
  }

  Future<void> resetDeleteButton() async {
    timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        delete = false;
      });
    });
  }


}