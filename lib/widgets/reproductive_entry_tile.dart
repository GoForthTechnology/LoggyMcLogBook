import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/widgets/crud_tile.dart';

class ReproductiveEntryTile extends StatefulWidget {
  final ReproductiveCategoryEntry entry;
  final Function(ReproductiveCategoryEntry entry) onRemove;
  final Function(ReproductiveCategoryEntry, ReproductiveCategoryEntry) onSave;

  const ReproductiveEntryTile(
      {super.key,
      required this.entry,
      required this.onRemove,
      required this.onSave});

  @override
  State<ReproductiveEntryTile> createState() => _ReproductiveEntryTileState();
}

class _ReproductiveEntryTileState extends State<ReproductiveEntryTile> {
  var dateController = TextEditingController();

  @override
  void initState() {
    dateController.text = widget.entry.sinceDate.toIso8601String();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var title =
        "${widget.entry.category.code} ${widget.entry.category.toString().split(".").last}";
    var subtitle = "Since ${widget.entry.sinceDate.toIso8601String()}";

    return CrudTile(
        title: title,
        subtitle: subtitle,
        contents: [
          TextFormField(
            decoration: InputDecoration(label: Text("Starting Date")),
            controller: dateController,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: widget.entry.sinceDate,
                firstDate: widget.entry.sinceDate.subtract(Duration(days: 366)),
                lastDate: widget.entry.sinceDate.add(Duration(days: 366)),
              );
              if (picked != null) {
                setState(() {
                  dateController.text = picked.toIso8601String();
                });
              }
            },
          ),
        ],
        showSave: () =>
            dateController.text != widget.entry.sinceDate.toIso8601String(),
        onSave: () => widget.onSave(
            widget.entry,
            ReproductiveCategoryEntry(
                category: widget.entry.category,
                sinceDate: DateTime.parse(dateController.text))),
        onRemove: () => widget.onRemove(widget.entry));
  }
}
