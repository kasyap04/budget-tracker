import 'package:flutter/material.dart';
import '../../utils/constant.dart';


// ignore: must_be_immutable
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget{

  AppBarWidget({super.key, required this.title, required this.back, this.currentContext, this.returnValue, this.action});
  final String title ;
  final bool back ;
  late BuildContext? currentContext ;
  late dynamic returnValue ;
  late List<Widget>? action ;

  @override
  Size get preferredSize => const Size.fromHeight(50) ;

  void goBack(){
    Navigator.of(currentContext!).pop(returnValue) ;
  }

  @override
  Widget build(BuildContext context){
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: Text(title, style: TextStyle(color: primaryColor),),
      backgroundColor: Colors.white,
      leading: back ? IconButton(onPressed: goBack, icon:const Icon(Icons.arrow_back_ios), color: primaryColor,) : null,
      actions: action,
    ) ;
  }
}