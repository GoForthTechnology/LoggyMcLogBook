import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/models/reproductive_category_model.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/reproductive_category_dialog.dart';
import 'package:provider/provider.dart';

class ReproductiveHistoryPanel extends StatelessWidget {
  final String clientID;

  const ReproductiveHistoryPanel({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
      builder: (context, repo, child) => StreamBuilder(
        stream: repo.stream(clientID),
        builder: (context, snapshot) => ExpandableInfoPanel(
            title: "Reproductive History",
            subtitle: "",
            contents: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 1,
                      child: ReproductiveCategoryColumn(
                        clientID: clientID,
                      )),
                  Flexible(flex: 1, child: PregnancyColumn()),
                  Flexible(flex: 1, child: ChildrenColumn()),
                ],
              )
            ]),
      ),
    );
  }
}

class ReproductiveCategoryColumn extends StatelessWidget {
  final String clientID;

  const ReproductiveCategoryColumn({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReproductiveCategoryModel>(
        builder: (context, model, child) =>
            StreamBuilder<List<ReproductiveCategoryEntry>>(
              stream: model.entries(clientID),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                var entries = snapshot.data ?? [];
                entries.sort((a, b) => b.sinceDate.compareTo(a.sinceDate));
                var updateButton = ElevatedButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => NewReproductiveCategoryDialog(
                              clientID: clientID,
                              previousEntry:
                                  entries.isEmpty ? null : entries.first,
                            )),
                    child: Text("Update"));
                return ListColumn(
                    title: "Reproductive Category",
                    trailing: updateButton,
                    children: [
                      ...entries
                          .map((entry) => ReproductiveEntryTile(
                                entry: entry,
                                onRemove: (entry) =>
                                    model.removeEntry(clientID, entry),
                                onSave: (existingEntry, newEntry) async {
                                  await model.removeEntry(
                                      clientID, existingEntry);
                                  await model.addEntry(clientID, newEntry);
                                },
                              ))
                          .toList(),
                    ]);
              },
            ));
  }
}

class PregnancyColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(
          "Pregnancies",
          style: Theme.of(context).textTheme.titleMedium,
        )),
        FakePregnancy(subtitle: "Delivered Fake Baby #1", dueDate: "5/5/2002"),
        FakePregnancy(subtitle: "Miscarried", dueDate: "5/5/2008"),
        FakePregnancy(subtitle: "Delivered Fake Baby #2", dueDate: "5/5/2022"),
        ElevatedButton(onPressed: () {}, child: Text("Add Pregnancy")),
      ],
    );
  }
}

class ChildrenColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListColumn(title: "Children", children: [
      FakeBaby(name: "Fake Baby #1"),
      FakeBaby(name: "Fake Baby #2"),
    ]);
  }
}

class ListColumn extends StatefulWidget {
  final String title;
  final Widget? trailing;
  final int maxItems;
  final List<Widget> children;

  const ListColumn({
    super.key,
    this.maxItems = 3,
    this.trailing,
    required this.title,
    required this.children,
  });

  @override
  State<ListColumn> createState() => _ListColumnState();
}

class _ListColumnState extends State<ListColumn> {
  var showAll = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = widget.children;
    if (!showAll) {
      items = items.sublist(0, min(items.length, widget.maxItems));
    }
    Widget showHideWidget = showAll
        ? TextButton(
            onPressed: () {
              setState(() {
                showAll = false;
              });
            },
            child: Text("Show Less"))
        : TextButton(
            onPressed: () {
              setState(() {
                showAll = true;
              });
            },
            child: Text("Show All"));

    return Column(
      children: [
        Center(
            child: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium,
        )),
        ...items,
        if (widget.children.length > widget.maxItems) showHideWidget,
        if (widget.trailing != null) widget.trailing!
      ],
    );
  }
}

final _notNullOrEmpty = (String? value) {
  if (value == null || value.isEmpty) {
    return "Value required";
  }
  return null;
};

class FakeBaby extends StatelessWidget {
  final String name;
  final _dateController = TextEditingController();

  FakeBaby({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(title: name, subtitle: "Age 6", contents: [
      TextFormField(
        initialValue: name,
        decoration: InputDecoration(label: Text("Name")),
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: "Date of Birth",
        ),
        validator: _notNullOrEmpty,
        controller: _dateController,
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(Duration(days: 90)),
            lastDate: DateTime.now().add(Duration(days: 365)),
          );
          if (picked != null) {
            _dateController.text = picked.toIso8601String();
          }
        },
      ),
      Center(child: TextButton(onPressed: () {}, child: Text("REMOVE"))),
    ]);
  }
}

class FakePregnancy extends StatelessWidget {
  final String dueDate;
  final String subtitle;

  const FakePregnancy(
      {super.key, required this.subtitle, required this.dueDate});

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
        title: "Due Date $dueDate",
        subtitle: subtitle,
        contents: [
          TextFormField(
            initialValue: dueDate,
            decoration: InputDecoration(label: Text("Due Date")),
          ),
          Row(
            children: [
              Text("Miscarrage?"),
              Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),
          Center(child: TextButton(onPressed: () {}, child: Text("REMOVE"))),
        ]);
  }
}

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
    return Consumer<ReproductiveCategoryModel>(
        builder: (context, model, child) => ExpandableInfoPanel(
              title: title,
              subtitle: "Since ${widget.entry.sinceDate.toIso8601String()}",
              contents: [
                TextFormField(
                  decoration: InputDecoration(label: Text("Starting Date")),
                  controller: dateController,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: widget.entry.sinceDate,
                      firstDate:
                          widget.entry.sinceDate.subtract(Duration(days: 366)),
                      lastDate: widget.entry.sinceDate.add(Duration(days: 366)),
                    );
                    if (picked != null) {
                      setState(() {
                        dateController.text = picked.toIso8601String();
                      });
                    }
                  },
                ),
                Center(
                    child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Spacer(),
                    if (_showSave())
                      IconButton(
                        icon: Icon(Icons.save),
                        onPressed: _saveEntry,
                      ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: _confirmRemoval,
                    ),
                    Spacer(),
                  ],
                ))
              ],
            ));
  }

  bool _showSave() {
    return dateController.text != widget.entry.sinceDate.toIso8601String();
  }

  void _saveEntry() {
    widget.onSave(
        widget.entry,
        ReproductiveCategoryEntry(
            category: widget.entry.category,
            sinceDate: DateTime.parse(dateController.text)));
  }

  void _confirmRemoval() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Confirm Delete"),
              content: Text("Are you sure you want to delete this item?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      widget.onRemove(widget.entry);
                      Navigator.of(context).pop();
                    },
                    child: Text("Confirm")),
              ],
            ));
  }
}
