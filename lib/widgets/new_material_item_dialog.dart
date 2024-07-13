import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/repos/materials.dart';

class NewItemDialog extends StatefulWidget {
  final MaterialsRepo repo;
  final MaterialItem? item;

  const NewItemDialog({super.key, required this.repo, this.item});

  @override
  State<NewItemDialog> createState() => _NewItemDialogState();
}

class _NewItemDialogState extends State<NewItemDialog> {
  var displayNameController = TextEditingController();
  var defaultPriceController = TextEditingController();
  var reoderPointController = TextEditingController();
  var languageController = TextEditingController();
  Language? language;

  @override
  void initState() {
    var item = widget.item;
    if (item == null) {
      _updateLanguage(Language.english);
      reoderPointController.text = "0";
      defaultPriceController.text = "0";
    } else {
      _updateLanguage(item.language);
      displayNameController.text = item.displayName;
      reoderPointController.text = item.reorderQuantity.toString();
      defaultPriceController.text =
          item.defaultPrices[Currency.USD]!.toString();
    }

    super.initState();
  }

  void _updateLanguage(Language? language) {
    languageController.text = language?.name ?? "";
    this.language = language;
  }

  Future<void> _saveItem() async {
    var messenger = ScaffoldMessenger.of(context);
    var navigator = Navigator.of(context);
    try {
      if (widget.item == null) {
        await widget.repo.createItem(MaterialItem(
          language: language!,
          defaultPrices: {Currency.USD: int.parse(defaultPriceController.text)},
          displayName: displayNameController.text,
          reorderQuantity: int.parse(reoderPointController.text),
          currentQuantity: 0,
        ));
      } else {
        await widget.repo.updateItem(widget.item!.copyWith(
          language: language,
          defaultPrices: {Currency.USD: int.parse(defaultPriceController.text)},
          reorderQuantity: int.parse(reoderPointController.text),
          displayName: displayNameController.text,
        ));
      }
      messenger.showSnackBar(const SnackBar(
        content: Text("Success!"),
      ));
    } catch (e, s) {
      print("$e $s");
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Item"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _saveItem,
          child: const Text("Save"),
        ),
      ],
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add a type of item to materials tracking."),
            TextFormField(
              decoration: const InputDecoration(label: Text("Display Name")),
              controller: displayNameController,
            ),
            TextFormField(
              decoration:
                  const InputDecoration(label: Text("Default Price (USD)")),
              controller: defaultPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextFormField(
              decoration:
                  const InputDecoration(label: Text("Restock Quantity")),
              controller: reoderPointController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: DropdownMenu<Language>(
                    width: 200,
                    label: const Text("Language"),
                    onSelected: (l) => setState(() => _updateLanguage(l)),
                    controller: languageController,
                    dropdownMenuEntries: Language.values
                        .map((l) => DropdownMenuEntry(value: l, label: l.name))
                        .toList())),
          ]),
    );
  }
}
