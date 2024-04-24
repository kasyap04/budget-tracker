import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';


import '../widgets/common/appbar.dart';
import '../widgets/form/input.dart';
import '../widgets/form/passwordFeild.dart';
import '../widgets/common/primaryButton.dart';
import '../utils/constant.dart';
import '../utils/common.dart';
import '../controller/registerLoginController/registerLoginController.dart';
import 'login.dart';

class ForgotPassword extends StatefulWidget{
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => ForgotPasswordState() ;
}

class ForgotPasswordState extends State<ForgotPassword>{

  final CommonUtil commonUtil = CommonUtil() ;

  final TextEditingController emailController     = TextEditingController() ;
  final TextEditingController password1Controller = TextEditingController() ;
  final TextEditingController password2Controller = TextEditingController() ;

  final RegisterLoginController controller        = RegisterLoginController() ;
  final formKey           = GlobalKey<FormState>();
  final passwordFormKey   = GlobalKey<FormState>();

  int otpSend = 1 ;
  dynamic OTP   = "" ; 

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        back: true,
        currentContext: context,
        title: "Reset password",
      ),
      body: getDisplayWidget(size)
    ) ;
  }


  Widget getDisplayWidget(Size size) {
    if(otpSend == 2){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text("We've send an OTP to ${emailController.text}", style: const TextStyle(color: Colors.grey))
            ),
            const Padding(padding: EdgeInsets.only(bottom: 30)),
            OtpTextField(
              numberOfFields: 5,
              borderColor: primaryColor,
              focusedBorderColor: primaryColor,
              showFieldAsBox: true, 
              onCodeChanged: (String code) {        
              },
              onSubmit: (String verificationCode){
                  OTP = verificationCode ;
              },
            ),
            SizedBox(
              width: size.width,
              child: PrimaryButton(
                top: 30,
                buttonName: "CONFIRM", 
                action: () => verifyOTP(context)
              ),
            )
          ],
        ),
      ) ;
    } else if(otpSend == 1){
      return        Padding(
         padding: const EdgeInsets.symmetric(horizontal: 10),
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Form(
               key: formKey,
               child: InputFeild(
                 controller: emailController,
                 label: "Enter your email",
                 validator: (value) => commonUtil.inputValidator(value),
               ),
             ),
             SizedBox(
               width: size.width,
               child: PrimaryButton(
                 top: 20,
                 buttonName: "Send OTP", 
                 action: () => sendOTP(context)
               ),
             ),
           ],
         ),
       ) ;
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: passwordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PasswordFeild(
                    label: "Choose password",
                    controller: password1Controller,
                    validator: (value) => controller.passwordValidator(value),
                    bottom: 20,
                  ),
                  PasswordFeild(
                    label: "Confirm password",
                    controller: password2Controller,
                    validator: (value) => controller.password2Validator(value, password1Controller),
                  ),
                  SizedBox(
                    width: size.width,
                    child: PrimaryButton(
                      top: 30,
                      buttonName: "Change password", 
                      action: () => changePassword(context)
                    ),
                  )
                ],
              )
            ),
          )
        ],
      ) ;
    }
  }


  void changePassword(BuildContext context) async {
    if(passwordFormKey.currentState!.validate()){
      String pass1 = password1Controller.text.toString() ;
      String email = emailController.text.toString() ;

      bool status = await controller.changeForgottenPassword(context, pass1, email) ;
      if(status){
        if(!context.mounted) return ;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context){
            return const LoginPage(
              haveBackButton: false,
            );
            }), (r){
            return false;
          });
      }
    }
  }

  void sendOTP(BuildContext context) async {
    if(formKey.currentState!.validate()){
      String email  = emailController.text.toString() ;
      await controller.sendOTPForResetPassword(context, email) ;
      setState(() {
        otpSend = 2 ;
      });
    }
  }

  void verifyOTP(BuildContext context) async {
    print("OTP = $OTP") ;
    if(OTP.isNotEmpty) {
      String email  = emailController.text.toString() ;
      bool status = await controller.verifyOTP(context, OTP, email) ;

      if(status){
        setState(() {
          otpSend = 3 ;
        });
      }

    }
  }

}