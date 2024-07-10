import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/child.dart';
import 'package:lmlb/models/child_model.dart';
import 'package:provider/provider.dart';

class ChildDialog extends StatefulWidget {
  final String clientID;

  const ChildDialog({super.key, required this.clientID});

  @override
  State<ChildDialog> createState() => _ChildDialogState();
}

class _ChildDialogState extends State<ChildDialog> {
  final formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var dateOfBirthController = TextEditingController();
  var notecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AlertDialog(
        title: const Text("New Child"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(label: Text("Name")),
              controller: nameController,
              validator: ((value) {
                if (value == null || value == "") {
                  return "Value required";
                }
                return null;
              }),
            ),
            TextFormField(
              decoration: const InputDecoration(label: Text("Date of Birth")),
              controller: dateOfBirthController,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  dateOfBirthController.text = picked.toIso8601String();
                }
              },
              validator: ((value) {
                if (value == null || value == "") {
                  return "Value required";
                }
                return null;
              }),
            ),
            TextFormField(
              decoration: const InputDecoration(label: Text("Notes")),
              controller: notecontroller,
              maxLines: null,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => AutoRouter.of(context).pop(),
              child: const Text("Cancel")),
          Consumer<ChildModel>(
              builder: (context, model, child) => TextButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      var child = Child(
                        name: nameController.text,
                        dateOfBirth: DateTime.parse(dateOfBirthController.text),
                        note: notecontroller.text,
                      );
                      var router = AutoRouter.of(context);
                      await model.addChild(widget.clientID, child);
                      router.pop();
                    }
                  },
                  child: const Text("Submit"))),
        ],
      ),
    );
  }
}
