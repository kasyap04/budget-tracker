import 'package:flutter/material.dart';

class SwitchTime extends StatelessWidget{
  final double width ;
  final double height ;
  final String value ;
  final void Function() backward ;
  final void Function() forward ;
  const SwitchTime({super.key, required this.width, required this.height, required this.backward, required this.forward, required this.value});

  @override
  Widget build(BuildContext context){
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 232, 232, 232),
          borderRadius: BorderRadius.circular(8)
        ),
        width: width,
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            button(
              icon: Icons.arrow_back_ios,
              action: backward,
            ),
            Text(value, style: const TextStyle(fontSize: 14)),
            button(
              icon: Icons.arrow_forward_ios,
              action: forward
            )
          ],
        ),
      ) ;
  }


  Widget button({required IconData icon, required void Function() action}) {
    return SizedBox(
      // height: 30,
      width: 40,
      child: IconButton(
        iconSize: 20,
        color: Colors.grey,
        onPressed: action, 
        icon: Icon(icon),
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero
        ),
      ),
    ) ;
  }
}