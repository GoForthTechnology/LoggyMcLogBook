import 'package:flutter/material.dart';
import 'package:lmlb/entities/child.dart';
import 'package:lmlb/widgets/crud_tile.dart';

class ChildTile extends StatefulWidget {
  final Child child;
  final Function(Child child) onRemove;
  final Function(Child, Child) onSave;

  const ChildTile(
      {super.key,
      required this.child,
      required this.onRemove,
      required this.onSave});

  @override
  State<ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<ChildTile> {
  var nameController = TextEditingController();
  var dateOfBirthController = TextEditingController();
  var notesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    dateOfBirthController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    nameController.text = widget.child.name;
    nameController.addListener(() => setState(() {}));
    dateOfBirthController.text = widget.child.dateOfBirth.toIso8601String();
    notesController.text = widget.child.note ?? "";
    notesController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var age = DateTime.now().difference(widget.child.dateOfBirth);
    int yearsOld = age.inDays ~/ 365;
    var subtitle = "Age $yearsOld";
    if (yearsOld == 0) {
      subtitle = "Age ${age.inDays ~/ 30} months";
    }

    return CrudTile(
        title: widget.child.name,
        subtitle: subtitle,
        contents: [
          TextFormField(
            decoration: const InputDecoration(label: Text("Name")),
            controller: nameController,
          ),
          TextFormField(
            decoration: const InputDecoration(label: Text("Date of Birth")),
            controller: dateOfBirthController,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: widget.child.dateOfBirth,
                firstDate: widget.child.dateOfBirth
                    .subtract(const Duration(days: 366)),
                lastDate:
                    widget.child.dateOfBirth.add(const Duration(days: 366)),
              );
              if (picked != null) {
                setState(() {
                  dateOfBirthController.text = picked.toIso8601String();
                });
              }
            },
          ),
          TextFormField(
            decoration: const InputDecoration(label: Text("Notes")),
            controller: notesController,
            maxLines: null,
          ),
        ],
        showSave: () {
          if (dateOfBirthController.text !=
              widget.child.dateOfBirth.toIso8601String()) {
            return true;
          }
          if (nameController.text != widget.child.name) {
            return true;
          }
          if (notesController.text != widget.child.note) {
            return true;
          }
          return false;
        },
        onSave: () => widget.onSave(
            widget.child,
            Child(
              name: nameController.text,
              dateOfBirth: DateTime.parse(dateOfBirthController.text),
              note: notesController.text,
            )),
        onRemove: () => widget.onRemove(widget.child));
  }
}
