import 'package:flutter/material.dart';

import '../widgets/common/appbar.dart';
import '../widgets/form/input.dart';
import '../widgets/form/textInput.dart';
import '../widgets/form/passwordFeild.dart';
import '../controller/registerLoginController/registerLoginController.dart';
import '../utils/common.dart';
import '../utils/constant.dart';
import '../screen/otpVerificationPage.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState() ;
}

class RegisterPageState extends State<RegisterPage>{
  RegisterLoginController controller    = RegisterLoginController() ;
  TextEditingController emailController = TextEditingController() ;
  TextEditingController nameController = TextEditingController() ;
  TextEditingController password1Controller = TextEditingController() ;
  TextEditingController password2Controller = TextEditingController() ;

  CommonUtil util = CommonUtil() ;
  final formKey   = GlobalKey<FormState>();
  bool isLoading = false ;

  Future<void> sendOtp() async {

    setState(() {
      isLoading = true ;
    });

    bool otpStatus = await controller.sendOTP(emailController.text.toString()) ;

    setState(() {
      isLoading = false ;
    });

    if(otpStatus){
     // ignore: use_build_context_synchronously
     Navigator.push(context, MaterialPageRoute(builder: (context) => OTPVerificationPage(
                  registerData: {
                    'email' : emailController.text,
                    'name' : nameController.text,
                    'password' : password1Controller.text
                  },
                ))) ;
    } else {
      print("API ERROR") ;
    }

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBarWidget(title: "", back: false),
      body: ListView(
        padding: const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text("Welcome", style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 45
          )),
          const Text("Register to your personal Budget Tracker", style: TextStyle(
            color: Colors.grey,
            fontSize: 15
          )),
            ],
          ),
            const Padding(padding: EdgeInsets.only(bottom: 50)),
          Form(
            key: formKey,
            child: Column(
            children: [
          InputFeild(
            label: "Enter your email",
            controller: emailController,
            bottom: 20,
            validator: (value) => controller.emailVaidator(value)
          ),
          TextInputFeild(
            controller: nameController,
            label: "Enter you fullname",
            bottom: 20,
            validator: (value) => util.inputValidator(value),
          ),
          PasswordFeild(
            controller: password1Controller,
            label: "Choose password",
            bottom: 20,
          validator: (value) => controller.passwordValidator(value)
          ),
          PasswordFeild(
            controller: password2Controller,
            label: "Confirm password",
            bottom: 30,
            validator: (value) => controller.password2Validator(value, password1Controller)
          ),
           RegisterButton(
            isLoading: isLoading,
            action: () async {
              if(formKey.currentState!.validate()){
               await sendOtp() ;
              }
            }
           ),
           LoginButton(
            action: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(haveBackButton: true,) )) ;
            },
           )
            ],
          )
          )
        ],
      ),
    ) ;
  }
}


class RegisterButton extends StatelessWidget{
  final void Function() action ;
  final bool isLoading ;
  const RegisterButton({super.key, required this.action, required this.isLoading});

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("REGISTER", style: TextStyle(fontSize: 20),),
           const  Padding(padding: EdgeInsets.only(right: 20)),
 
            Visibility(
              visible: isLoading, 
              child: const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color:  Color.fromARGB(255, 197, 195, 197),
                strokeWidth: 2,
              ),
            ))
          ],
        )
      ),
    ) ;
  }
}



class LoginButton extends StatelessWidget{
  final void Function() action ;
  const LoginButton({super.key, required this.action});

  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have account?", style: TextStyle(color: Colors.grey),),
        TextButton(onPressed: action, child: Text("Login", style: TextStyle(color: primaryColor),))
      ],
    ) ;
  }
}