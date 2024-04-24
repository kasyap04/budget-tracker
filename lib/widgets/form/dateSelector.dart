import 'package:flutter/material.dart';

import '../../utils/constant.dart';



// ignore: must_be_immutable
class DateSelector extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double width;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  late bool? selectDate;
  late dynamic Function(dynamic value)? validator;
  DateSelector(
      {super.key,
      this.selectDate,
      this.validator,
      required this.label,
      required this.controller,
      required this.width,
      required this.firstDate,
      required this.lastDate,
      required this.initialDate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: labelColor, fontSize: 12),
          ),
          TextFormField(
            readOnly: true,
            controller: controller,
            cursorColor: primaryColor,
            decoration: InputDecoration(
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
            onTap: () async {
              DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate);

              String fullTime = "";

              fullTime = date != null ? date.toString().substring(0, 10) : "";

              if (date != null && (selectDate != null || selectDate == true)) {
                // ignore: use_build_context_synchronously
                TimeOfDay? timePicker = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());

                if (timePicker != null) {
                  dynamic hour = timePicker.hour > 9
                      ? timePicker.hour
                      : "0${timePicker.hour}";

                  dynamic minute = timePicker.minute > 9
                      ? timePicker.minute
                      : "0${timePicker.minute}";

                  fullTime = "$fullTime $hour:$minute:00";
                }
              }

              controller.text = fullTime;
            },
            validator: (value) =>  validator!(value) ,
          ),
        ],
      ),
    );
  }
}