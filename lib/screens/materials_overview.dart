import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/repos/materials.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class MaterialsOverviewScreen extends StatelessWidget {
  const MaterialsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRailScreen(
        item: NavigationItem.materials,
        title: const Text('Materials'),
        content: Consumer<MaterialsRepo>(
            builder: (context, repo, child) => Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CurrentInventoryPanel(repo: repo),
                      const RestockOrdersPanel(),
                      const ClientOrdersPanel(),
                    ],
                  ),
                ))));
  }
}

class CurrentInventoryPanel extends StatelessWidget {
  final MaterialsRepo repo;

  const CurrentInventoryPanel({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MaterialItem>>(
      stream: repo.currentInventory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        var items = snapshot.data!;
        var itemsBelowReorderPoint =
            items.where((i) => i.currentQuantity <= i.reorderQuantity).length;
        var subtitle = items.isEmpty
            ? "No items"
            : itemsBelowReorderPoint > 0
                ? "$itemsBelowReorderPoint items to reorder"
                : "";
        return ExpandableInfoPanel(
            title: "Current Inventory",
            subtitle: subtitle,
            trailing: Tooltip(
                message: "Add New Item",
                child: IconButton(
                    onPressed: () => showDialog(
                          context: context,
                          builder: (context) => NewItemDialog(repo: repo),
                        ),
                    icon: const Icon(Icons.add))),
            contents: items.map((i) {
              int numBeforeReorder = i.currentQuantity - i.reorderQuantity;
              return OverviewTile(
                attentionLevel: numBeforeReorder <= 0
                    ? OverviewAttentionLevel.red
                    : numBeforeReorder < 0.5 * i.reorderQuantity
                        ? OverviewAttentionLevel.yellow
                        : OverviewAttentionLevel.grey,
                title: i.displayName,
                subtitle: "Current quantity ${i.currentQuantity}",
                icon: Icons.palette,
                actions: [
                  OverviewAction(
                    title: "EDIT",
                    onPress: () => showDialog(
                      context: context,
                      builder: (context) => NewItemDialog(
                        repo: repo,
                        item: i,
                      ),
                    ),
                  )
                ],
              );
            }).toList());
      },
    );
  }
}

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

class RestockOrdersPanel extends StatelessWidget {
  const RestockOrdersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableInfoPanel(
        title: "Restock Orders",
        subtitle: "No orders pending",
        contents: [Placeholder()]);
  }
}

class ClientOrdersPanel extends StatelessWidget {
  const ClientOrdersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableInfoPanel(
        title: "Client Orders",
        subtitle: "No orders pending",
        contents: [Placeholder()]);
  }
}
