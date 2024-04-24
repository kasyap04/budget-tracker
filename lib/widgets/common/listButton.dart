import 'package:flutter/material.dart';


class ListButton extends StatelessWidget{
  final String label ;
  final void Function() action ;
  final IconData icon ;
  const ListButton({super.key, required this.label, required this.action, required this.icon});

  @override
  Widget build(BuildContext context){
    return ElevatedButton(
    onPressed: action,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(244, 193, 128, 205),
      shape: const StadiumBorder()
    ),
    child: Row(
      children: [
        Icon(icon),
        Text("  $label")
      ],
    )
    ) ;
  }
}