import 'package:flutter/material.dart';

class SuggestionHistory extends StatelessWidget{
  final String mySugg ;
  final String myDate ;
  final String reply ;
  final String replyDate ;
  const SuggestionHistory({super.key, required this.mySugg, required this.myDate, required this.reply, required this.replyDate});

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromARGB(31, 89, 89, 89)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mySugg),
          gap(10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(myDate, style: const TextStyle(fontSize: 12, color: Colors.grey),),
          ),
          gap(20),
          if(reply.isNotEmpty) Container(
            width: size.width,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reply),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(replyDate, style: const TextStyle(fontSize: 12, color: Colors.grey),),
                ),
              ],
            ),
          )
        ],
      ),
    ) ;
  }


  Widget gap(double width) => Padding(padding: EdgeInsets.only(bottom: width)) ;

}