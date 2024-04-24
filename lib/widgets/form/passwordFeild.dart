import 'package:flutter/material.dart';

import '../../utils/constant.dart';

// ignore: must_be_immutable
class PasswordFeild extends StatefulWidget{
  @override
  State<PasswordFeild> createState() => PasswordFeildState() ;

    final TextEditingController controller;
  late double? width;
  late String? label;
  late String? hint;
  late double? bottom;
  late dynamic Function(dynamic value)? validator;
  PasswordFeild(
      {super.key,
      required this.controller,
      this.label,
      this.hint,
      this.bottom,
      this.validator,
      this.width});
}

class PasswordFeildState extends State<PasswordFeild> {


  bool obsecureText = true ;
  IconData passwordIcon = Icons.visibility ;


  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label ?? "",
            style: TextStyle(color: labelColor, fontSize: 12),
          ),
          TextFormField(
            controller: widget.controller,
            cursorColor: primaryColor,
            obscureText: obsecureText,
            decoration: InputDecoration(
              suffix: PasswordButton(
                action: () => setState(() {
                    obsecureText = !obsecureText ;

                    if(obsecureText){
                      passwordIcon = Icons.visibility ;
                    } else {
                        passwordIcon = Icons.visibility_off ;
                    }
                }),
                icon: passwordIcon,
              ),
                hintText: widget.hint ?? "",
                hintStyle: const TextStyle(fontSize: 14),
                prefixIconConstraints: const BoxConstraints(
                    maxHeight: 20, maxWidth: 50, minWidth: 20, minHeight: 10),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8)),
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius:
                        BorderRadius.circular(8))),
            validator: (value) =>  widget.validator!(value) ,
          ),
          Padding(padding: EdgeInsets.only(bottom: widget.bottom ?? 0))
        ],
      ),
    );
  }
}


class PasswordButton extends StatelessWidget{
  final IconData icon ;
  final void Function() action ;
  const PasswordButton({super.key, required this.icon, required this.action});

  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 20,
      child: IconButton(
        iconSize: 20,
        constraints: const BoxConstraints(
          maxHeight: 20,
        ),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          fixedSize: const Size(10, 10),
        ),
        onPressed: action, 
        icon: Icon(icon, color: Colors.grey,)),
    ) ;
  }
}