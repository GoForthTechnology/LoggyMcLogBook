import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lmlb/entities/child.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/client_general_info.dart';
import 'package:lmlb/entities/pregnancy.dart';
import 'package:lmlb/models/child_model.dart';
import 'package:lmlb/models/pregnancy_model.dart';
import 'package:lmlb/models/reproductive_category_model.dart';
import 'package:lmlb/repos/gif_repo.dart';
import 'package:lmlb/widgets/child_dialog.dart';
import 'package:lmlb/widgets/child_tile.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/pregnancy_dialog.dart';
import 'package:lmlb/widgets/pregnancy_tile.dart';
import 'package:lmlb/widgets/reproductive_category_dialog.dart';
import 'package:lmlb/widgets/reproductive_entry_tile.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ReproductiveHistoryPanel extends StatelessWidget {
  final Client client;
  final String? titleOverride;

  const ReproductiveHistoryPanel(
      {super.key, required this.client, this.titleOverride});

  Stream<String> subtitleStream(
      Client client,
      ReproductiveCategoryModel categoryModel,
      GifRepo gifRepo,
      PregnancyModel pregnancyModel,
      ChildModel childModel) {
    return Rx.combineLatest4<String, String, int, int, String>(
        categoryModel.entries(client.id!).map((entries) {
          if (entries.isEmpty) {
            return "Reproductive Category Unknown";
          }
          entries.sort(
            (a, b) => b.sinceDate.compareTo(a.sinceDate),
          );
          return entries.first.category.toString();
        }),
        gifRepo.get(GeneralInfoItem.NAME_MAN, client.id!),
        pregnancyModel.numPregancies(client.id!).asStream(),
        childModel.numChildren(client.id!).asStream(),
        (categoryStr, spouceName, numPregnancies, numChildren) {
      String out = "${client.firstName} ${client.lastName}";
      if (spouceName.isNotEmpty) {
        out = "$out & $spouceName";
      }
      var pregnancyStr = numPregnancies == 1 ? "Pregnancy" : "Pregnancies";
      var childStr = numChildren == 1 ? "Child" : "Children";
      out =
          "$out -- $categoryStr, $numPregnancies $pregnancyStr, $numChildren $childStr";
      return out;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ReproductiveCategoryModel, PregnancyModel, ChildModel,
        GifRepo>(
      builder: (context, categoryModel, pregnancyModel, childModel, gifRepo,
              child) =>
          StreamBuilder(
        stream: subtitleStream(
            client, categoryModel, gifRepo, pregnancyModel, childModel),
        builder: (context, snapshot) => ExpandableInfoPanel(
            title: titleOverride ?? "Reproductive History",
            subtitle: !snapshot.hasData ? "" : snapshot.data as String,
            contents: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 1,
                      child: ReproductiveCategoryColumn(
                        clientID: client.id!,
                      )),
                  Flexible(
                      flex: 1,
                      child: PregnancyColumn(
                        clientID: client.id!,
                      )),
                  Flexible(
                      flex: 1,
                      child: ChildrenColumn(
                        clientID: client.id!,
                      )),
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
                            onRemove: (p) => model.removePregnancy(clientID, p),
                            onSave: (updatedPregnancy) async {
                              await model.removePregnancy(clientID, p);
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
  final String clientID;

  const ChildrenColumn({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChildModel>(
        builder: (context, model, child) => StreamBuilder<List<Child>>(
            stream: model.children(clientID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              var children = snapshot.data ?? [];
              children.sort((a, b) => a.dateOfBirth.compareTo(b.dateOfBirth));
              return ListColumn(
                  title: "Children",
                  children: children
                      .map((c) => ChildTile(
                            child: c,
                            onRemove: (p) => model.removeChild(clientID, p),
                            onSave: (existingChild, updatedChild) async {
                              await model.removeChild(clientID, existingChild);
                              await model.addChild(clientID, updatedChild);
                            },
                          ))
                      .toList(),
                  trailing: ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ChildDialog(clientID: clientID),
                    ),
                    child: Text("Add Child"),
                  ));
            }));
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
