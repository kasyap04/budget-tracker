import 'package:budget_tracker/utils/constant.dart';
import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/profile/personalInfo.dart';
import '../widgets/profile/currencyIcon.dart';
import '../widgets/profile/cards.dart';
import '../widgets/profile/suggestionWidget.dart';
import '../controller/profileController.dart';
import '../utils/common.dart';
import 'login.dart';


class Profile extends StatefulWidget{
  final String currencyCode ;
  const Profile({super.key, required this.currencyCode});

  @override
  State<Profile> createState() => ProfileState() ;
}

class ProfileState extends State<Profile>{
  final ProfileController profileController = ProfileController() ;
  final CommonUtil commonUtil = CommonUtil() ;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        back: true,
        currentContext: context,
        title: "Profile",
        // action: [logoutButton(context)],
      ), 
      body: FutureBuilder(
        future: profileController.getPersonalDetails(context), 
        builder: (context, snapshot){
          dynamic userData  = {} ;
          if(snapshot.hasData){
              userData = snapshot.data ;
              // print("userData = $userData") ;
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              const Align(
                alignment: Alignment.center,
                child: Icon(Icons.person_sharp, color: Color.fromARGB(136, 158, 158, 158), size: 150,),
              ),
              gap(20),
              PersonalInfo(
                userDetails : userData,
                savedAction: () => setState(() {}),
              ),
              gap(20),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: expantionHeader("Currency icon"),
                children: [
                  CurrencyIcon(
                    currencyCode: widget.currencyCode,
                  )
                ],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: expantionHeader("Cards"),
                children: const [
                  Align(alignment: Alignment.centerLeft, child: Cards())
                ],
              ),
              gap(30),
              if(userData.isNotEmpty) ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: primaryColor
                ),
                onPressed: () => backupRecovery(context, userData['expense_status'], userData['userId']), 
                icon: Icon(userData['expense_status'] ? Icons.backup_outlined : Icons.restore_outlined), 
                label: Text( userData['expense_status'] ? "BACKUP" : "RESTORE")
              ),
              gap(30),
              SuggestionWidget(
                userId: userData.isNotEmpty ? userData['userId'] : 0,
                isLoading: userData.isEmpty,
              )
            ],
          ) ;
        }
      ),
    ) ;
  }

  void backupRecovery(BuildContext context, bool expenseStatus, int userId) async {
    if(expenseStatus) {
      await profileController.backup(context, userId) ;
    } else {
      await profileController.restore(context, userId) ;
      setState(() {});
    }

    
  }

  Widget gap(double height) => Padding(padding: EdgeInsets.only(top: height)) ;
  Widget expantionHeader(String titile) => Text(titile, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)) ;

  Widget logoutButton(BuildContext context) => TextButton(
    onPressed: () async {
      bool status = await profileController.logoutApp() ;

      if(!context.mounted) return ;

      if(!status){
        commonUtil.showSnakBar(context: context, msg: "Can't logout now! Please try again later", error: true) ;
        return;
      }

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context){
        return const LoginPage(
          haveBackButton: false,
        );
      }), (r){
        return false;
      });
  
    }, 
    child: Text("Logout", style: TextStyle(color: primaryColor),)
  ) ;
}