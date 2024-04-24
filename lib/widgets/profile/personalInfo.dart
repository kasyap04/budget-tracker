import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../../widgets/common/headerText.dart';
import '../../widgets/common/primaryButton.dart';
import '../../widgets/common/secondaryButton.dart';
import '../../widgets/form/input.dart';
import '../../widgets/form/passwordFeild.dart';
import '../../utils/common.dart';
import '../../controller/profileController.dart';

class PersonalInfo extends StatefulWidget{
  final Map userDetails ;
  final void Function() savedAction ;
  const PersonalInfo({super.key, required this.userDetails, required this.savedAction});

  @override
  State<PersonalInfo> createState() => PersonalInfoState() ;
}


class PersonalInfoState extends State<PersonalInfo> {
  final TextEditingController nameController        = TextEditingController() ;
  final TextEditingController emailController       = TextEditingController() ;
  final TextEditingController passwordController    = TextEditingController() ;

  final ProfileController profileController = ProfileController() ;

  final CommonUtil commonUtil = CommonUtil() ;
  final GlobalKey<FormState> formKey  = GlobalKey<FormState>();

  bool editMode = false ;

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;

    if(widget.userDetails.isNotEmpty){
      nameController.text     = widget.userDetails['username'] ;
      passwordController.text = widget.userDetails['password'] ;
      emailController.text    = widget.userDetails['email'] ;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderText(name: "Personal details", bottom: 10),
            TextButton.icon(
              onPressed: () => setState(() => editMode = true), 
              icon: const Icon(Icons.edit, size: 16, color: Colors.grey,), 
              label: const Text("Edit", style: TextStyle(color: Colors.grey),)
            )
          ],
        ),
        !editMode ?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userData(label: "username", value: widget.userDetails.isNotEmpty ? widget.userDetails['username'] : ""),
            gap(20),
            userData(label: "email", value: widget.userDetails.isNotEmpty ? widget.userDetails['email'] : ""),
            gap(20),
            userData(label: "Password", value: "*******")
          ],
        )
        :
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFeild(
                label: "username",
                controller: nameController,
                validator: (value) => commonUtil.inputValidator(value, msg: "Please enter your username"),
              ),
              gap(20),
              InputFeild(
                label: "email",
                controller: emailController,
                validator: (value) => commonUtil.inputValidator(value, msg: "Please enter your email"),
              ),
              gap(20),
              PasswordFeild(
                label: "password",
                controller: passwordController,
                validator: (value) => commonUtil.inputValidator(value, msg: "Please enter a password"),
              ),
              gap(25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: (size.width / 2) - 15,
                    child: SecondaryButton(buttonName: "Cancel", action: () => setState(() => editMode = false))
                  ),
                  SizedBox(
                    width: (size.width / 2) - 15,
                    child: PrimaryButton(
                      buttonName: "Save", 
                      action: () => saveUserData(context)
                    ),
                  ),
                ],
              )
            ],
          ),
        ),

      ],
    ) ;
  }


  void saveUserData(BuildContext context) async {
    if(formKey.currentState!.validate()){

      Map<String, dynamic> data = {
        'username' : nameController.text,
        'email' : emailController.text,
        'password' : passwordController.text,
        'user_id' : widget.userDetails['userId'].toString()
      } ;

      bool status = await profileController.saveUser(context, data) ;

      if(status){
        editMode = false ;
        widget.savedAction() ;
      }
    }
  }

    Widget userData({required String label, required String value}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        value.isNotEmpty 
        ? 
        Text(value, style: const TextStyle(fontSize: 20),)
        :
        const SkeletonLine(
          style: SkeletonLineStyle(
            height: 50
          ),
        )
      ],
    ) ;

    Widget gap(double height) => Padding(padding: EdgeInsets.only(top: height)) ;
}