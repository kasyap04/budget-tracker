import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constant.dart';
import '../../utils/common.dart';

// ignore: must_be_immutable
class AmountFeild extends StatelessWidget {
  final TextEditingController controller;
  final String countryCode ;
  late double? width;
  late String? label;
  late String? hint;
  late double? bottom;
  late double? top;
  late dynamic Function(dynamic value)? validator;
  AmountFeild(
      {super.key,
      required this.controller,
      required this.countryCode,
      this.label,
      this.hint,
      this.bottom,
      this.top,
      this.validator,
      this.width});

  final CommonUtil util = CommonUtil() ;

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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
            ],
            cursorColor: primaryColor,
            decoration: InputDecoration(
              prefix: Icon(util.currencyIcon(countryCode), size: 13, color: Colors.grey,),
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
          Padding(padding: EdgeInsets.only(bottom: bottom ?? 0, top: top ?? 0))
        ],
      ),
    );
  }
}