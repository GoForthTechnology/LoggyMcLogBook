
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:provider/provider.dart';

class NewClientDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewClientDialogState();
}

class _NewClientDialogState extends State<NewClientDialog> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(builder: (context, clientRepo, child) => AlertDialog(
      title: Text("New Client"),
      content: ConstrainedBox(constraints: BoxConstraints(maxWidth: 400), child: form()),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text("Cancel")),
        TextButton(onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            var client = Client(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
            );
            await clientRepo.newClient(client).then((client) {
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("New client added successfully")));
            }, onError: (error) {
              Navigator.of(context).pop();

              print("Error adding new client $error");
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error adding new client!"), ));
            });
          }
        }, child: Text("Submit")),
      ],
    ));
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: "First Name *",
            icon: Icon(Icons.person),
          ),
          validator: _valueMustNotBeEmpty,
          controller: _firstNameController,
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: "Last Name *",
            icon: Icon(Icons.person),
          ),
          validator: _valueMustNotBeEmpty,
          controller: _lastNameController,
        ),
      ],),
    );
  }

  String? _valueMustNotBeEmpty(String? value) {
    if (value?.isNotEmpty ?? false) {
      return null;
    }
    return "Value required";
  }
}
