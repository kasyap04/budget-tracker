import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../widgets/common/appbar.dart';
import '../utils/constant.dart';
import '../controller/registerLoginController/registerLoginController.dart';
import 'home.dart';

// ignore: must_be_immutable
class OTPVerificationPage extends StatelessWidget{
  final Map<String, String> registerData ;
  OTPVerificationPage({super.key, required this.registerData});

  final RegisterLoginController controller = RegisterLoginController() ;

  dynamic OTP = "" ; 




  Future<void> callRegistrationAPI(String otp, BuildContext context) async{
    registerData['otp'] = otp ;
    dynamic response = await controller.register(registerData) ;
    
    if(response){
      await controller.crearAllData() ;

      if(!context.mounted) return ;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context){
        return const HomePage();
      }), (r){
        return false;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    String email=registerData['email'].toString();

    return Scaffold(
      appBar: AppBarWidget(title: "Verification", back: true, currentContext: context,),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               const Padding(padding: EdgeInsets.only(top: 50)),
               const Text("Verify OTP", style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35
            ),),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Text("Please enter OTP that we send on the mail $email", style: const TextStyle(color: Colors.grey),)
              ],
            ),
            OtpTextField(
          numberOfFields: 5,
          borderColor: primaryColor,
          focusedBorderColor: primaryColor,
          showFieldAsBox: true, 
          onCodeChanged: (String code) {
              //handle validation or checks here           
          },
          onSubmit: (String verificationCode){
              OTP = verificationCode ;
          }, // end onSubmit
          ),
          ConfirmButton(action: () =>  {
            callRegistrationAPI(OTP, context) 
          }),
            const Padding(padding: EdgeInsets.only(top: 58)),
            
            
      
          ],
        ),
      ),
    ) ;
  }
}



class ConfirmButton extends StatelessWidget{
  final void Function() action ;
  const ConfirmButton({super.key, required this.action});

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          elevation: 0,
          padding: const EdgeInsets.all(15)
        ),
        onPressed: action, 
        child: const Text("CONFIRM", style: TextStyle(fontSize: 20),)),
    ) ;
  }
}