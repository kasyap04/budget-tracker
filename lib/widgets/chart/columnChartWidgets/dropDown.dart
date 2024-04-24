import 'package:flutter/material.dart';


class DropDown extends StatelessWidget{
  final void Function(dynamic value) valueChanged ;
  final double width ;
  final double height;
  final String defaultValue ;
  const DropDown({super.key, required this.valueChanged, required this.width, required this.height, required this.defaultValue});

  @override
  Widget build(BuildContext context){
    List<DropdownMenuItem> items = const [
       DropdownMenuItem(
        value: "weekly",
        child: Text("Weekly", style: TextStyle(fontSize: 14)),
      ),
       DropdownMenuItem(
        value: "monthly",
        child: Text("Monthly", style: TextStyle(fontSize: 14)),
      ),
       DropdownMenuItem(
        value: "yearly",
        child: Text("Yearly", style: TextStyle(fontSize: 14)),
      ),
    ] ;
    
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DropdownButtonFormField(
          value: defaultValue,
          items: items, 
          onChanged: (value) => valueChanged(value),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color.fromARGB(255, 232, 232, 232),
              contentPadding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 0),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none
          ),
        ),
      ),
    );
  }
}