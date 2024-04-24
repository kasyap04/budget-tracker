import 'package:flutter/material.dart';

import '../widgets/form/input.dart';
import '../widgets/form/passwordFeild.dart';
import '../widgets/common/appbar.dart';
import '../utils/constant.dart';
import '../controller/registerLoginController/registerLoginController.dart';
import 'home.dart';
import 'register.dart';
import 'forgotPassword.dart';



class LoginPage extends StatefulWidget{
  final bool haveBackButton ;
  const LoginPage({super.key, required this.haveBackButton});

  @override
  State<LoginPage> createState() => LoginPageState() ;
}

class LoginPageState extends State<LoginPage>{
  RegisterLoginController controller        = RegisterLoginController() ;
  TextEditingController emailController     = TextEditingController() ;
  TextEditingController passwordController = TextEditingController() ;
  final formKey   = GlobalKey<FormState>();

  bool isLoading = false ;
  String loginError = "" ;


  Future<void> callLoginApi(BuildContext context) async {
    setState(() {
      isLoading = true ;
    });

    Map<String, dynamic> loginData = {
      'email'     : emailController.text,
      'password'  : passwordController.text
    } ;

    dynamic login_response = await controller.login(loginData, context) ;

    

    setState(() {
      isLoading = false ;
    });

    // print("login_response = $login_response") ;

    if(login_response['status']){
      if(!context.mounted) return ;

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context){
        return const HomePage();
      }), (r){
        return false;
      });

    } else {
      if(login_response['method'] != 'snackbar'){
        setState(() {
          loginError = login_response['msg'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBarWidget(back: widget.haveBackButton, currentContext: context, title: ""),
      body: Padding(padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 30)),
      
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back", style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 35
                  )),
                  const Text("Login to Budget Tracker", style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15
                  )),
                  const Padding(padding: EdgeInsets.only(bottom: 40)),
                  InputFeild(
                  label: "Enter your email",
                  controller: emailController,
                  bottom: 20,
                  validator: (value) => controller.emailVaidator(value)
                ),
                PasswordFeild(
                  controller: passwordController,
                  label: "Enter your password",
                  bottom: 0,
                validator: (value) => controller.passwordValidator(value)
                ),
                Text(loginError, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 20,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero
                      ),
                      onPressed: () => routeForgotPasswod(context), 
                      child: Text("Forgot password?", style: TextStyle(color: primaryColor),)
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 20)),
                LoginButton(
                  action: (){
                    if(formKey.currentState!.validate()){
                      callLoginApi(context) ;
                    }
                  },
                  isLoading: isLoading,
                ),
                if(!widget.haveBackButton) Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New user?"),
                    TextButton(
                      onPressed: () => routeRegister(context), 
                      child: Text("Register", style: TextStyle(color: primaryColor))
                    )
                  ],
                )
                ],
              )
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30))
      
          ],
        ),
        ]
      ),
      ),
    ) ;
  }

  void routeRegister(BuildContext context){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context){
        return const RegisterPage();
      }), (r){
        return false;
      });
  }

  void routeForgotPasswod(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPassword()
      )
    ) ;
  }

}


class LoginButton extends StatelessWidget{
  final void Function() action ;
  final bool isLoading ;
  const LoginButton({super.key, required this.action, required this.isLoading});

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
            const Text("LOGIN", style: TextStyle(fontSize: 20),),
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