import 'package:flutter/material.dart';

import '../../utils/constant.dart';

// ignore: must_be_immutable
class DescriptionInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double width;
  late dynamic Function(dynamic value)? validator;
  DescriptionInput(
      {super.key,
      required this.controller,
      this.validator,
      required this.hintText,
      required this.width});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: width,
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        controller: controller,
        textAlign: TextAlign.center,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.only(top: 30, bottom: 5, left: 20, right: 20),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14),
          prefixIconConstraints: const BoxConstraints(
              maxHeight: 20, maxWidth: 50, minWidth: 20, minHeight: 10),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor)),
          errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor)),
        ),
        // onTapOutside: (value) => focus.unfocus(),
         validator: (value) => validator!(value),
      ),
    );
  }
}