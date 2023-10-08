import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:provider/provider.dart';

class NewClientModel extends ChangeNotifier {

  final formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  Currency? currency;

  void updateCurrency(Currency? currency) {
    this.currency = currency;
    notifyListeners();
  }

  Client client() {
    // TODO: fix this to actually set the spouse name
    return Client(null, null, firstNameController.text, lastNameController.text, "", currency, true);
  }
}

class NewClientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => NewClientModel(), child: Scaffold(
      appBar: AppBar(
        title: Text("New Client"),
        actions: [
          Consumer2<Clients, NewClientModel>(builder: (context, clientRepo, model, child) => TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () => onSave(context, clientRepo, model),
          ))
        ],
      ),
      body: _inputForm(),
    ));
  }

  void onSave(BuildContext context, Clients clientRepo, NewClientModel model) {
    if (!model.formKey.currentState!.validate()) {
      print("Invalid Form");
      return;
    }
    clientRepo.add(model.client()).then((client) {
      AutoRouter.of(context).popAndPush(ClientDetailsScreenRoute(clientId: client.id));
    });
  }

  Widget _inputForm() {
    return Consumer<NewClientModel>(builder: (context, model, child) => Form(
      key: model.formKey,
      child: Column(children: [
        _buildFirstName(model),
        _buildLastName(model),
        _buildCurrencySelector(model),
      ]),
    ));
  }

  Widget _buildFirstName(NewClientModel model) {
    return _textInput("First Name:", model.firstNameController);
  }

  Widget _buildLastName(NewClientModel model) {
    return _textInput("Last Name:", model.lastNameController);
  }

  Widget _buildCurrencySelector(NewClientModel model) {
    var widget = DropdownButtonFormField<Currency>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      hint: Text('Please make a selection'),
      value: model.currency,
      items: Currency.values.map((enumValue) {
        return DropdownMenuItem<Currency>(
          value: enumValue,
          child: new Text(enumValue.toString().split(".")[1]),
        );
      }).toList(),
      onChanged: (selection) => model.updateCurrency(selection),
      validator: (value) {
        if (value == null) {
          return "Selection required";
        }
        return null;
      },
    );
    return _inputWidget("Currency:", widget);
  }

  static Widget _textInput(String title, TextEditingController controller) {
    Widget child = TextFormField(
      autofocus: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: controller,
    );
    return _inputWidget(title, child);
  }

  static Widget _inputWidget(String title, Widget child) {
    return Row(
      children: [
        Container(
          child: Text(title),
          margin: EdgeInsets.only(right: 10.0),
        ),
        Expanded(child: child),
      ],
    );
  }
}