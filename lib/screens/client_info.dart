import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/models/clients.dart';
import 'package:provider/provider.dart';

class ClientInfoScreenArguments {
  final Client? client;

  ClientInfoScreenArguments(this.client);
}

class ClientInfoScreen extends StatelessWidget {
  static const routeName = '/client';

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute
        .of(context)!
        .settings
        .arguments as ClientInfoScreenArguments;
    return ClientInfoForm(args.client);
  }
}

class ClientInfoForm extends StatefulWidget {
  final Client? _client;

  ClientInfoForm(this._client);

  @override
  State<StatefulWidget> createState() {
    return ClientInfoFormState(_client);
  }
}

class ClientInfoFormState extends State<ClientInfoForm> {
  final Client? _client;

  ClientInfoFormState(this._client);

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _firstNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_client == null ? 'New Client' : 'Client Info'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(primary: Colors.white),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _onSave,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFirstName(),
              _buildLastName(),
              if (_client != null) _buildClientNum(),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final clients = Provider.of<Clients>(context, listen: false);
      var clientNum = _client?.num;
      if (clientNum == null) {
        clients.add(_firstNameController.value.text, _lastNameController.value.text);
      } else {
        clients.update(
            Client(clientNum, _firstNameController.value.text, _lastNameController.value.text));
      }
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildClientNum() {
    var clientNum = _client?.displayNum().toString();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            child: Text("Client Num:"),
            margin: EdgeInsets.only(right: 10.0),
          ),
          Text(clientNum == null ? "NULL" : clientNum),
        ]
      ),
    );
  }

  Widget _buildFirstName() {
    return _textInput(
        "First Name:", _client?.firstName, _firstNameController, true);
  }

  Widget _buildLastName() {
    return _textInput(
        "Last Name:", _client?.lastName, _lastNameController, false);
  }

  static Widget _textInput(String title, String? value,
      TextEditingController controller, bool autoFocus) {
    if (value != null) {
      controller.text = value;
    }
    return Row(
      children: [
        Container(
          child: Text(title),
          margin: EdgeInsets.only(right: 10.0),
        ),
        Expanded(
          child: TextFormField(
              autofocus: autoFocus && value == null,
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              }),
        ),
      ],
    );
  }
}
