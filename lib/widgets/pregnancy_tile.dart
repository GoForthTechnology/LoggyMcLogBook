import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmlb/entities/pregnancy.dart';
import 'package:lmlb/widgets/crud_tile.dart';

class PregnancyTile extends StatefulWidget {
  final Pregnancy pregnancy;
  final Function(Pregnancy) onRemove;
  final Function(Pregnancy) onSave;

  const PregnancyTile(
      {super.key,
      required this.pregnancy,
      required this.onRemove,
      required this.onSave});

  @override
  State<PregnancyTile> createState() => _PregnancyTileState();
}

class _PregnancyTileState extends State<PregnancyTile> {
  var dueDateController = TextEditingController();
  var misscarrageDateController = TextEditingController();
  var deliveryDateController = TextEditingController();
  var notesController = TextEditingController();

  @override
  void dispose() {
    dueDateController.dispose();
    misscarrageDateController.dispose();
    deliveryDateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    dueDateController.text = widget.pregnancy.dueDate.toIso8601String();
    notesController.text = widget.pregnancy.note ?? "";
    deliveryDateController.text =
        widget.pregnancy.dateOfDelivery?.toIso8601String() ?? "";
    misscarrageDateController.text =
        widget.pregnancy.dateOfLoss?.toIso8601String() ?? "";
    notesController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CrudTile(
        title:
            "Due Date ${DateFormat.yMMMd().format(widget.pregnancy.dueDate)}",
        subtitle: "",
        contents: [
          TextFormField(
            decoration: const InputDecoration(label: Text("Due Date")),
            controller: dueDateController,
            onTap: () async {
              final DateTime? picked = await promptForDate(
                  initialDate: DateTime.parse(dueDateController.text));
              if (picked != null) {
                setState(() {
                  dueDateController.text = picked.toIso8601String();
                });
              }
            },
          ),
          if (misscarrageDateController.text.isNotEmpty)
            Row(
              children: [
                Flexible(
                    child: TextFormField(
                  decoration:
                      const InputDecoration(label: Text("Miscarrage Date")),
                  controller: misscarrageDateController,
                )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        misscarrageDateController.text = "";
                      });
                    },
                    icon: const Icon(Icons.clear)),
              ],
            ),
          if (deliveryDateController.text.isNotEmpty)
            Row(
              children: [
                Flexible(
                    child: TextFormField(
                  decoration:
                      const InputDecoration(label: Text("Delivery Date")),
                  controller: deliveryDateController,
                )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        deliveryDateController.text = "";
                      });
                    },
                    icon: const Icon(Icons.clear)),
              ],
            ),
          TextFormField(
            decoration: const InputDecoration(label: Text("Notes")),
            controller: notesController,
            maxLines: null,
          ),
          if (showOutcomeButtons())
            Row(
              children: [
                TextButton(
                    onPressed: () async {
                      var date = await promptForDate();
                      setState(() {
                        misscarrageDateController.text =
                            date?.toIso8601String() ?? "";
                      });
                    },
                    child: const Text("Record Miscarrage")),
                TextButton(
                    onPressed: () async {
                      var date = await promptForDate();
                      setState(() {
                        deliveryDateController.text =
                            date?.toIso8601String() ?? "";
                      });
                    },
                    child: const Text("Record Birth")),
              ],
            ),
        ],
        showSave: () {
          if (dueDateController.text !=
              widget.pregnancy.dueDate.toIso8601String()) {
            return true;
          }
          if (deliveryDateController.text !=
              widget.pregnancy.dateOfDelivery?.toIso8601String()) {
            return true;
          }
          if (misscarrageDateController.text !=
              widget.pregnancy.dateOfLoss?.toIso8601String()) {
            return true;
          }
          if (notesController.text != widget.pregnancy.note) {
            return true;
          }
          return false;
        },
        onSave: () => widget.onSave(pregnancy()),
        onRemove: () => widget.onRemove(widget.pregnancy));
  }

  Pregnancy pregnancy() {
    DateTime? dateOfDelivery;
    if (deliveryDateController.text.isNotEmpty) {
      dateOfDelivery = DateTime.parse(deliveryDateController.text);
    }
    DateTime? dateOfMiscarrage;
    if (misscarrageDateController.text.isNotEmpty) {
      dateOfMiscarrage = DateTime.parse(misscarrageDateController.text);
    }
    return Pregnancy(
      dueDate: DateTime.parse(dueDateController.text),
      dateOfDelivery: dateOfDelivery,
      dateOfLoss: dateOfMiscarrage,
      note: notesController.text,
    );
  }

  bool showOutcomeButtons() {
    return deliveryDateController.text.isEmpty &&
        misscarrageDateController.text.isEmpty;
  }

  Future<DateTime?> promptForDate({DateTime? initialDate}) {
    return showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: initialDate ?? DateTime.now());
  }
}
