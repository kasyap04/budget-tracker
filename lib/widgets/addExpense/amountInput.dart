import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constant.dart';


class AmountInput extends StatelessWidget{
  final TextEditingController controller;
  final IconData icon ;
  const AmountInput({super.key, required this.controller, required this.icon});

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width / 2,
      child: ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: TextFormField(
      controller: controller,
      cursorColor: primaryColor,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
      ],
      style: const TextStyle(
        fontSize: 30,
      ),
      decoration: InputDecoration(
          hintText: "0",
          prefixIconConstraints: const BoxConstraints(
              maxHeight: 20, maxWidth: 50, minWidth: 20, minHeight: 10),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(
              icon,
              color: Colors.grey,
              size: 20,
            ),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
          filled: true,
          fillColor: primaryColor.withOpacity(0.1)),
    ),
      ),
    );
  }
}