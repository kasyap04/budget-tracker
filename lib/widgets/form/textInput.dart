import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constant.dart';

// ignore: must_be_immutable
class TextInputFeild extends StatelessWidget {
  final TextEditingController controller;
  late double? width;
  late String? label;
  late String? hint;
  late double? bottom;
  late dynamic Function(dynamic value)? validator;
  TextInputFeild(
      {super.key,
      required this.controller,
      this.label,
      this.hint,
      this.bottom,
      this.validator,
      this.width});
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? "",
            style: TextStyle(color: labelColor, fontSize: 12),
          ),
          TextFormField(
            controller: controller,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 ]'))
            ],
            textCapitalization: TextCapitalization.sentences,
            cursorColor: primaryColor,
            decoration: InputDecoration(
                hintText: hint ?? "",
                hintStyle: const TextStyle(fontSize: 14),
                prefixIconConstraints: const BoxConstraints(
                    maxHeight: 20, maxWidth: 50, minWidth: 20, minHeight: 10),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8)),
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius:
                        BorderRadius.circular(8))),
            validator: (value) =>  validator!(value) ,
          ),
          Padding(padding: EdgeInsets.only(bottom: bottom ?? 0))
        ],
      ),
    );
  }
}