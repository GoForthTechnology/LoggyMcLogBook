import 'package:flutter/material.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/repos/materials.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/new_material_item_dialog.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class CurrentInventoryPanel extends StatelessWidget {
  final bool showLeadingIcon;
  const CurrentInventoryPanel({super.key, this.showLeadingIcon = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialsRepo>(
        builder: (context, repo, child) => StreamBuilder<List<MaterialItem>>(
              stream: repo.currentInventory(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                var items = snapshot.data!;
                var itemsBelowReorderPoint = items
                    .where((i) => i.currentQuantity <= i.reorderQuantity)
                    .length;
                var subtitle = items.isEmpty
                    ? "No items"
                    : "$itemsBelowReorderPoint items to reorder";
                return ExpandableInfoPanel(
                    title: "Current Inventory",
                    subtitle: subtitle,
                    trailing: Tooltip(
                        message: "Add New Item",
                        child: IconButton(
                            onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      NewItemDialog(repo: repo),
                                ),
                            icon: const Icon(Icons.add))),
                    contents: items.map((i) {
                      int numBeforeReorder =
                          i.currentQuantity - i.reorderQuantity;
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
            ));
  }
}
