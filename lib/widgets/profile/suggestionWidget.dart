import 'package:flutter/material.dart';

import '../../widgets/common/headerText.dart';
import '../../widgets/form/multiLineInput.dart';
import '../../widgets/common/secondaryButton.dart';
import '../../utils/apiService.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../screen/suggestion.dart';


class SuggestionWidget extends StatelessWidget{
  final int userId ;
  final bool isLoading ;
  SuggestionWidget({super.key, required this.userId, required this.isLoading});

  final CommonUtil commonUtil = CommonUtil() ;
  final TextEditingController suggestionController = TextEditingController() ;

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderText(name: "Make your suggestion"),
            SizedBox(
              height: 30,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero
                ),
                onPressed: () => routeSuggestions(context), 
                icon: Icon(Icons.arrow_forward, color: primaryColor,), 
                label: Text("Show all", style: TextStyle(color: primaryColor),)
              ),
            )
          ],
        ),
        MultiInputFeild(controller: suggestionController),
        Align(
          alignment: Alignment.centerRight,
          child: SecondaryButton(
            buttonName: "Submit", 
            action: () => suggestionAction(context), 
            width: 100, 
            top: 10)
          )
      ],
    ) ;
  }

  void routeSuggestions(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Suggestion(userId: userId,)
      )
    ) ;
  }


  void suggestionAction(BuildContext context) async {
    if(isLoading){
      commonUtil.showSnakBar(context: context, msg: "No network connection", error: true) ;
      return ;
    }
    String suggestion = suggestionController.text ;

    Map<String, dynamic> body = {
      'data'    : suggestion,
      'user_id' : userId.toString()
    } ;

    String path = "add-suggestion" ;

    dynamic data = await postAPI(path, body) ;

    if(data['status']){
      suggestionController.text = "" ;
    }

    if(!context.mounted) return ;
    commonUtil.showSnakBar(context: context, msg: data['msg'], error: !data['status']) ;


  }


}