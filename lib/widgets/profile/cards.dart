import 'dart:async';
import 'package:flutter/material.dart';

import '../form/textInput.dart';
import '../common/primaryButton.dart';
import '../common/secondaryButton.dart';
import '../../controller/profileController.dart';
import '../../utils/constant.dart';
import '../../utils/common.dart';

class Cards extends StatefulWidget{
  const Cards({super.key});

  @override
  State<Cards> createState() => CardsState() ;
}

class CardsState extends State<Cards>{
  final ProfileController profileController = ProfileController() ;
  final TextEditingController cardNameController = TextEditingController() ;
  final GlobalKey<FormState> formKey  = GlobalKey<FormState>();
  final CommonUtil commonUtil = CommonUtil() ;

  double addCardHeight = 0 ;
  int editcardId = 0 ;

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size ;
    double cardWidth = (size.width / 2) - 15 ;

    return FutureBuilder(
      future: profileController.getAllCards(), 
      builder: (context, snapdata){
        
        List<Widget> children = [] ;
        dynamic allCards      = [] ;

        if(snapdata.hasData){
          allCards = snapdata.data ;
          
          for (var card in allCards) {
            children.add(
              ExpenseCard(
              width: cardWidth,
              cardActive: card['status'] == 1,
              cardId: card['id'],
              cardName: card['card_name'],
              switchChanges: (status, cardId) => switchAction(context, cardId, status),
              editAction: (cardId) => setState(() {
                editcardId    = cardId ;
                addCardHeight = 150 ;
                cardNameController.text = card['card_name'] ;
              } ),
              deleteAction: (cardId) => delete(context, cardId),
            )
            ) ;
          }

          children.add(addCard(
            onPressed: () => setState(() {
              editcardId    = 0 ;
              addCardHeight = 150 ;
              cardNameController.text = "" ;
            } ),
            width: cardWidth
          )) ;

        }


        return Column(
          children: [
            Wrap(
              spacing: 10,
              children: children,
            ), 
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            AnimatedContainer(
              height: addCardHeight,
              duration: const Duration(milliseconds: 500),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Form(
                    key: formKey,
                    child: TextInputFeild(
                      label: "Card name",
                      hint: "Eg : Wallet card",
                      controller: cardNameController,
                      validator: (value) => commonUtil.inputValidator(value, msg: "Please enter card name"),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SecondaryButton(
                        width: cardWidth,
                        buttonName: "Cancel", 
                        action: () => setState(() {
                          cardNameController.text = "" ;
                          addCardHeight = 0 ;
                        })
                      ),
                      PrimaryButton(
                      width: cardWidth,
                      buttonName: "Save card", 
                      action: () => saveCard(context)
                    )
                    ],
                  )
                ],
              ),
            )
          ],
        ) ;
      }
    ) ;
  }

  void saveCard(BuildContext context) async {
    if(formKey.currentState!.validate()){
      String cardName = cardNameController.text ;

      if(editcardId == 0){
        await profileController.saveNewCard(context, cardName) ;
      } else {
        await profileController.editCard(context, cardName, editcardId) ;
      }
      cardNameController.text = "" ;
      setState(() {});
    }
  }

  void delete(BuildContext context, int cardId) async {
    await profileController.deleteCard(context, cardId) ;
    setState(() {});
  }

  void switchAction(BuildContext context, int cardId, bool status) async {
    print(cardId) ;
    await profileController.cardStatusToggle(context, cardId, status) ;
    // setState(() {});
  }

  Widget addCard({required double width, required void Function() onPressed}) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    width: width,
    height: 85,
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.4),
      borderRadius: BorderRadius.circular(8)
    ),
    child: IconButton(
      onPressed: onPressed,
      iconSize: 50,
      color: Colors.grey,
      icon: const Icon(Icons.add),
    ),
  ) ;
}

class ExpenseCard extends StatefulWidget{
  final double width ;
  final int cardId ;
  final String cardName ;
  final bool cardActive ;
  final void Function(bool status, int cardId) switchChanges ; 
  final void Function(int cardId) deleteAction ;
  final void Function(int cardId) editAction ;
  const ExpenseCard({super.key, required this.width, required this.switchChanges, required this.cardId, required this.cardName, required this.cardActive, required this.deleteAction, required this.editAction});

  @override
  State<ExpenseCard> createState() => ExpenseCardState();
}

class ExpenseCardState extends State<ExpenseCard> {

  bool active = true ;

  @override
  void initState(){
    super.initState();
    active = widget.cardActive ;
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: widget.width,
      height: 85,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: active ? primaryColor.withOpacity(0.25) : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 25,
              child: Transform.scale(
                scale: 0.8,
                child: Switch(
                  activeColor: primaryColor,
                  value: active, 
                  onChanged: (value) {
                    setState(() => active = !active);
                    widget.switchChanges(value, widget.cardId) ;
                  }
                ),
              ),
            ),
          ),
          Text(widget.cardName, style: TextStyle(
            color: active ? primaryColor : const Color.fromARGB(255, 98, 98, 98),
            fontSize: 16
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DeleteButton(
                onDelete: (id) => widget.deleteAction(id),
                cardId: widget.cardId,
              ),
              EditButton(
                cardId: widget.cardId,
                onEdit: (id) => widget.editAction(id),
              )
            ],
          ),
        ],
      ),
    ) ;
  }
}


class DeleteButton extends StatefulWidget{
  final void Function(int cardId) onDelete ;
  final int cardId ;
  const DeleteButton({super.key, required this.onDelete, required this.cardId});

  @override
  State<DeleteButton> createState() => DeleteButtonState() ;
}

class DeleteButtonState extends State<DeleteButton>{

  bool delete = false;

  late var timer;

  @override
  void initState() {
    super.initState();
    timer = null;
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 30,
      child: IconButton(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero
        ),
        iconSize: 20,
        color: const Color.fromARGB(255, 212, 29, 16),
        onPressed: (){
          setState(() {
            if(!delete){
              delete = true ;
              resetDeleteButton() ;
            } else {
              widget.onDelete(widget.cardId) ;
            }
          });
        }, 
        icon: Icon( delete ? Icons.done : Icons.delete)
      ),
    ) ;
  }

    Future<void> resetDeleteButton() async {
    timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        delete = false;
      });
    });
  }

}


class EditButton extends StatelessWidget{
  final void Function(int cardId) onEdit ;
  final int cardId ;
  const EditButton({super.key, required this.onEdit, required this.cardId});

  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 30,
      child: IconButton(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero
        ),
        iconSize: 20,
        color: primaryColor,
        onPressed: () => onEdit(cardId), 
        icon: const Icon(Icons.edit)
      ),
    ) ;
  }
}