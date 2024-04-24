import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'screen/home.dart';
import 'screen/register.dart';
import 'controller/home/homeController.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState() ;
}


 class MyAppState extends State<MyApp>{

  HomeController homeController = HomeController() ;
  // final _scaffoldKey = GlobalKey<ScaffoldMessengerState>() ;

  @override
  Widget build(BuildContext context) {
    

    return MaterialApp(
      // scaffoldMessengerKey: _scaffoldKey,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: homeController.getUser(), 
        builder: (context, snapshot){
          if(snapshot.hasData){

            FlutterNativeSplash.remove();


            dynamic haveUser = snapshot.data ;

            if(haveUser){
              return const HomePage() ;
            } else {
              return const RegisterPage() ;            
            }

          } else {
            return const Center(
              child: Text("Welcome to Budget Tracker"),
            ) ;
          }
        }),
    ) ;
  }

 }