import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/models/reproductive_category_model.dart';
import 'package:provider/provider.dart';

class NewReproductiveCategoryDialog extends StatefulWidget {
  final String clientID;
  final ReproductiveCategoryEntry? previousEntry;

  const NewReproductiveCategoryDialog(
      {super.key, this.previousEntry, required this.clientID});

  @override
  State<NewReproductiveCategoryDialog> createState() =>
      _NewReproductiveCategoryDialogState();
}

class _NewReproductiveCategoryDialogState
    extends State<NewReproductiveCategoryDialog> {
  final formKey = GlobalKey<FormState>();
  var dateController = TextEditingController();
  var notecontroller = TextEditingController();
  ReproductiveCategory? category;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: AlertDialog(
          title: const Text("New Repoductive Category"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<ReproductiveCategory>(
              items: ReproductiveCategory.values
                  .map((value) => DropdownMenuItem<ReproductiveCategory>(
                      value: value, child: Text(value.name)))
                  .toList(),
              validator: (value) {
                if (value == null) {
                  return "Value required";
                }
                return null;
              },
              onChanged: (value) {
                category = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(label: Text("Starting")),
              validator: _notNullOrEmpty,
              controller: dateController,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: widget.previousEntry == null
                      ? DateTime.now().subtract(const Duration(days: 90))
                      : widget.previousEntry!.sinceDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  dateController.text = picked.toIso8601String();
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(label: Text("Note")),
              controller: notecontroller,
              maxLines: null,
            )
          ]),
          actions: [
            TextButton(
                onPressed: () => AutoRouter.of(context).pop(),
                child: const Text("Cancel")),
            Consumer<ReproductiveCategoryModel>(
                builder: (context, model, child) => TextButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        var entry = ReproductiveCategoryEntry(
                          category: category!,
                          sinceDate: DateTime.parse(dateController.text),
                          note: notecontroller.text,
                        );
                        var router = AutoRouter.of(context);
                        await model.addEntry(widget.clientID, entry);
                        router.pop();
                      }
                    },
                    child: const Text("Submit"))),
          ],
        ));
  }
}

String? _notNullOrEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return "Value required";
  }
  return null;
}
