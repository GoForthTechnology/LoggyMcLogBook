import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/stream_widget.dart';
import 'package:rxdart/rxdart.dart';

class ClientInfoModel extends WidgetModel<ClientInfoState> {

  final Clients clientRepo;

  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();

  final StreamController<String> firstNameStreamController = new StreamController();
  final StreamController<String> lastNameStreamController = new StreamController();
  final StreamController<Currency?> currencyStreamController = new StreamController();

  Client? client;

  ClientInfoModel(this.clientRepo, String? clientId) {
    if (clientId != null) {
      clientRepo.stream(clientId).listen((client) {
        if (client == null) {
          throw Exception("Could not find client for id $clientId");
        }
        print("Updating view model with data from client repo");
        this.client = client;
        firstNameStreamController.add(client.firstName);
        lastNameStreamController.add(client.lastName);
        currencyStreamController.add(client.currency);
        notifyListeners();
      });
    }

    firstNameController.addListener(() => firstNameStreamController.add(firstNameController.text));
    lastNameController.addListener(() => lastNameStreamController.add(lastNameController.text));

    final clientS = clientId == null ? Stream.value(null) : clientRepo.stream(clientId);

    Rx.combineLatest4(
      clientS,
      firstNameStreamController.stream,
      lastNameStreamController.stream,
      currencyStreamController.stream,
      createState).listen((state) => updateState(state));
  }

  Future<void> assignClientNum(Client client) {
    return clientRepo.assignClientNum(client);
  }

  Future<void> save(ClientInfoState state) async {
    if (state.client?.id == null) {
      return clientRepo.add(
        state.firstName,
        state.lastName,
        state.currency!
      );
    }
    return clientRepo.update(Client(
      state.client?.id,
      state.client?.num,
      state.firstName,
      state.lastName,
      state.currency,
      state.client?.active,
    ));
  }

  ClientInfoState createState(Client? client, String firstName, String lastName, Currency? currency) {
    print("Creating new ClientInfoState");
    return ClientInfoState(client: client, firstName: firstName, lastName: lastName, currency: currency);
  }

  @override
  ClientInfoState initialState() {
    return new ClientInfoState();
  }
}

class ClientInfoState {
  final Client? client;
  final String firstName;
  final String lastName;
  final Currency? currency;

  ClientInfoState({
    this.client,
    this.firstName = "",
    this.lastName = "",
    this.currency,
  });
}

class ClientInfoWidget extends StreamWidget<ClientInfoModel, ClientInfoState> {

  @override
  Widget render(BuildContext context, ClientInfoState state,ClientInfoModel model) {
    print("Re-rendering");
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
        child: Text("Client Info", style: Theme.of(context).textTheme.titleMedium),
      ),
      _buildClientNum(state, model),
      _buildTextWidget("First Name:", Text(state.firstName)),
      _buildTextWidget("Last Name:", Text(state.lastName)),
      _buildTextWidget("Currency:", Text(state.currency?.name ?? "TBD")),
    ]);
  }


  Widget _buildClientNum(ClientInfoState state, ClientInfoModel model) {
    final client = state.client;
    if (client == null) {
      return Container();
    }
    var clientNum = client.num;
    var widget = clientNum == null
        ? ElevatedButton(onPressed: () => model.assignClientNum(client), child: Text("Assign Number"),)
        : Text(client.displayNum()!);
    return _buildTextWidget("Client Num:", widget);
  }

  Widget _buildTextWidget(String title, Widget widget) {
    return _paddedItem(Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        child: Text(title),
        margin: EdgeInsets.only(right: 10.0),
      ),
      widget,
    ]));
  }

  // ignore: unused_element
  Widget _buildFirstName(ClientInfoModel model, ClientInfoState state) {
    return _textInput(
        "First Name:", state.firstName, (text) => model.firstNameStreamController.add(text), true);
  }

  // ignore: unused_element
  Widget _buildLastName(ClientInfoModel model, ClientInfoState state) {
    return _textInput(
        "Last Name:", state.lastName, (text) => model.lastNameStreamController.add(text), false);
  }

  // ignore: unused_element
  Widget _buildCurrencySelector(ClientInfoModel model, ClientInfoState state) {
    var dropDownButton = DropdownButton<Currency>(
      hint: Text('Please make a selection'),
      items: Currency.values.map((enumValue) {
        return DropdownMenuItem<Currency>(
          value: enumValue,
          child: new Text(enumValue.toString().split(".")[1]),
        );
      }).toList(),
      onChanged: (selection) {
        model.currencyStreamController.add(selection);
      },
      value: state.currency,
    );
    var formField = FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) => dropDownButton,
    );
    return _inputWidget("Currency:", formField);
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

  static Widget _textInput(String title, String? value,
      void Function(String) onChanged, bool autoFocus) {
    print("FOO: $value");
    Widget child = TextFormField(
      autofocus: autoFocus && value == null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      initialValue: value,
      onChanged: onChanged,
    );
    return _inputWidget(title, child);
  }

  Widget _paddedItem(Widget child) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0), child: child);
  }
}