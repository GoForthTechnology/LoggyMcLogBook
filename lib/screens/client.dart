import 'package:flutter/material.dart';
import 'package:lmlb/models/clients.dart';
import 'package:provider/provider.dart';

class ClientScreenArguments {
  final Client? client;
  ClientScreenArguments(this.client);
}

class ClientScreen extends StatelessWidget {
  static const routeName = '/client';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ClientScreenArguments;
    return ClientForm(args.client);
  }
}

class ClientForm extends StatefulWidget {
  final Client? _client;

  ClientForm(this._client);

  @override
  State<StatefulWidget> createState() {
    return ClientFormState(_client);
  }
}

class ClientFormState extends State<ClientForm> {
  final Client? _client;

  ClientFormState(this._client);

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
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      Provider.of<Clients>(context, listen: false).add(
          _firstNameController.value.text,
          _lastNameController.value.text);
      Navigator.of(context).pop();
    }
  }

  Widget _buildFirstName() {
    return _textInput("First Name:", _client?.firstName, _firstNameController, true);
  }

  Widget _buildLastName() {
    return _textInput("Last Name:", _client?.lastName, _lastNameController, false);
  }

  static Widget _textInput(String title, String? value, TextEditingController controller, bool autoFocus) {
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
