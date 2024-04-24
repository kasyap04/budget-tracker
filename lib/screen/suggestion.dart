import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/suggesion/suggestionHistory.dart';
import '../controller/profileController.dart';


class Suggestion extends StatefulWidget{
  final int userId ;
  const Suggestion({super.key, required this.userId});


  @override
  State<Suggestion> createState() => SuggestionState() ;
}

class SuggestionState extends State<Suggestion>{
  final ProfileController controller = ProfileController() ;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        back: true,
        currentContext: context,
        title: "Suggestions",
      ), 
      body: FutureBuilder(
        future: controller.getSuggestions(widget.userId), 
        builder: (context, snapshot) {

          List<Widget> children = <Widget>[] ;

          if(snapshot.hasData){
              dynamic snapData = snapshot.data ;

              for (var row in snapData) {
                  children.add(
                    SuggestionHistory(
                      mySugg: row['body'],
                      myDate: row['date'],
                      reply: row['reply']['body'],
                      replyDate: row['reply']['date'],
                    )
                  ) ;
              }
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: children
          ) ;

        }
      )
    ) ;
  }
}