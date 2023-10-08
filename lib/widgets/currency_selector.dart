import 'package:flutter/material.dart';
import 'package:lmlb/entities/currency.dart';

class CurrencySelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CurrencySelectorState();
}

class CurrencySelectorState extends State<CurrencySelector> {
  Currency? selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: DropdownButtonFormField<Currency>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      hint: Text('Please make a selection'),
      value: selectedCurrency,
      items: Currency.values.map((enumValue) {
        return DropdownMenuItem<Currency>(
          value: enumValue,
          child: Text(enumValue.toString().split(".")[1]),
        );
      }).toList(),
      onChanged: (selection) => setState(() {
        selectedCurrency = selection;
      }),
      validator: (value) {
        if (value == null) {
          return "Selection required";
        }
        return null;
      },
    ));
  }
}