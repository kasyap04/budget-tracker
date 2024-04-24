import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../utils/constant.dart';


class DatePickerWidget extends StatelessWidget{
  const DatePickerWidget({super.key, required this.controller});

  final DateRangePickerController controller;

  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 280,
      width: 200,
      child: SfDateRangePicker(
        controller: controller,
        view: DateRangePickerView.month,
        selectionMode: DateRangePickerSelectionMode.extendableRange,
        todayHighlightColor: Colors.transparent,
        startRangeSelectionColor: primaryColor,
        endRangeSelectionColor: primaryColor,
        rangeSelectionColor: lightPrimaryColor,
        headerStyle: DateRangePickerHeaderStyle(
          textStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14
          )
        ),
      ),
    ) ;
  }
}


