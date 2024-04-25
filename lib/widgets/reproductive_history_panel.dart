import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/pregnancy.dart';
import 'package:lmlb/models/pregnancy_model.dart';
import 'package:lmlb/models/reproductive_category_model.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/pregnancy_dialog.dart';
import 'package:lmlb/widgets/pregnancy_tile.dart';
import 'package:lmlb/widgets/reproductive_category_dialog.dart';
import 'package:lmlb/widgets/reproductive_entry_tile.dart';
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
                  Flexible(
                      flex: 1,
                      child: PregnancyColumn(
                        clientID: clientID,
                      )),
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
  final String clientID;

  const PregnancyColumn({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyModel>(
        builder: (context, model, child) => StreamBuilder<List<Pregnancy>>(
            stream: model.pregnancies(clientID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              var pregnancies = snapshot.data ?? [];
              pregnancies.sort((a, b) => b.dueDate.compareTo(a.dueDate));
              return ListColumn(
                  title: "Pregnancies",
                  children: pregnancies
                      .map((p) => PregnancyTile(
                            pregnancy: p,
                            onRemove: (p) =>
                                model.removePregnancy(clientID, p.dueDate),
                            onSave: (updatedPregnancy) async {
                              await model.removePregnancy(clientID, p.dueDate);
                              await model.addPregnancy(
                                  clientID, updatedPregnancy);
                            },
                          ))
                      .toList(),
                  trailing: ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => PregnancyDialog(clientID: clientID),
                    ),
                    child: Text("Add Pregnancy"),
                  ));
            }));
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
