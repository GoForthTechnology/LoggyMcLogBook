import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/pregnancy.dart';
import 'package:lmlb/models/pregnancy_model.dart';
import 'package:provider/provider.dart';

class PregnancyDialog extends StatefulWidget {
  final String clientID;

  const PregnancyDialog({super.key, required this.clientID});

  @override
  State<PregnancyDialog> createState() => _PregnancyDialogState();
}

class _PregnancyDialogState extends State<PregnancyDialog> {
  final formKey = GlobalKey<FormState>();
  var dateController = TextEditingController();
  var notecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AlertDialog(
        title: Text("New Pregnancy"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(label: Text("Due Date")),
              controller: dateController,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(Duration(days: 365)),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  dateController.text = picked.toIso8601String();
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
              decoration: InputDecoration(label: Text("Notes")),
              controller: notecontroller,
              maxLines: null,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => AutoRouter.of(context).pop(),
              child: Text("Cancel")),
          Consumer<PregnancyModel>(
              builder: (context, model, child) => TextButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      var pregnancy = Pregnancy(
                          dueDate: DateTime.parse(dateController.text));
                      await model.addPregnancy(widget.clientID, pregnancy);
                      AutoRouter.of(context).pop();
                    }
                  },
                  child: Text("Submit"))),
        ],
      ),
    );
  }
}
