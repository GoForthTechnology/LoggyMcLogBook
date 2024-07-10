import 'package:flutter/material.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:provider/provider.dart';

class NewClientDialog extends StatefulWidget {
  const NewClientDialog({super.key});

  @override
  State<StatefulWidget> createState() => _NewClientDialogState();
}

class _NewClientDialogState extends State<NewClientDialog> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
        builder: (context, clientRepo, child) => AlertDialog(
              title: const Text("New Client"),
              content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: form()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await clientRepo
                            .newClient(_firstNameController.text,
                                _lastNameController.text)
                            .then((client) {
                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("New client added successfully")));
                        }, onError: (error) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Error adding new client!"),
                          ));
                        });
                      }
                    },
                    child: const Text("Submit")),
              ],
            ));
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: "First Name *",
              icon: Icon(Icons.person),
            ),
            validator: _valueMustNotBeEmpty,
            controller: _firstNameController,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Last Name *",
              icon: Icon(Icons.person),
            ),
            validator: _valueMustNotBeEmpty,
            controller: _lastNameController,
          ),
        ],
      ),
    );
  }

  String? _valueMustNotBeEmpty(String? value) {
    if (value?.isNotEmpty ?? false) {
      return null;
    }
    return "Value required";
  }
}
