import 'package:flutter/material.dart';

import '../../utils/constant.dart';

class CardSelector extends StatelessWidget {
  final double width;
  final String label;
  final List<Map> menuItems;
  final String selectedCardId;
  final void Function(String value) cardChanged;
  const CardSelector(
      {super.key,
      required this.width,
      required this.label,
      required this.cardChanged,
      required this.menuItems,
      required this.selectedCardId});

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> cards = [];

    cards.add(const DropdownMenuItem(value: "", child: Text("")));
    for (var item in menuItems) {
      cards.add(DropdownMenuItem(
          value: item['id'].toString(), child: Text(item['card_name'])));
    }

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: labelColor, fontSize: 12),
          ),
          DropdownButtonFormField(
              value: selectedCardId != "0" ? selectedCardId : "",
              iconSize: 18,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius:
                          BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius:
                          BorderRadius.circular(8)),
                  errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius:
                          BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius:
                          BorderRadius.circular(8))),
              items: cards,
              onChanged: (value) => cardChanged(value)),
        ],
      ),
    );
  }
}