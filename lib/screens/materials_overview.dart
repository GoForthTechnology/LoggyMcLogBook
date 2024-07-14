import 'package:flutter/material.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/repos/materials.dart';
import 'package:lmlb/widgets/client_orders_panel.dart';
import 'package:lmlb/widgets/current_inventory_panel.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/new_material_restock_order_dialog.dart';
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
                      const CurrentInventoryPanel(),
                      RestockOrdersPanel(repo: repo),
                      const ClientOrdersPanel(
                        title: "Client Orders",
                      ),
                    ],
                  ),
                ))));
  }
}

class RestockOrdersPanel extends StatelessWidget {
  final MaterialsRepo repo;

  const RestockOrdersPanel({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RestockOrder>>(
        stream: repo.restockOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var orders = snapshot.data!;
          orders.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
          var numOutstanding =
              orders.where((o) => o.dateReceived == null).length;
          return ExpandableInfoPanel(
            title: "Restock Orders",
            subtitle: "$numOutstanding order(s) pending",
            trailing: Tooltip(
                message: "Add New Order",
                child: IconButton(
                    onPressed: () => showDialog(
                          context: context,
                          builder: (context) => NewRestockOrderDialog(
                            repo: repo,
                            editingEnabled: true,
                          ),
                        ),
                    icon: const Icon(Icons.add))),
            contents: orders.map((o) => _orderTile(context, o)).toList(),
          );
        });
  }

  Widget _orderTile(BuildContext context, RestockOrder order) {
    List<OverviewAction> actions = [];
    if (order.dateReceived == null) {
      actions = [
        OverviewAction(
            title: "Edit",
            onPress: () => showDialog(
                context: context,
                builder: (context) => NewRestockOrderDialog(
                      repo: repo,
                      order: order,
                      editingEnabled: true,
                    ))),
      ];
    } else {
      actions = [
        OverviewAction(
            title: "View",
            onPress: () => showDialog(
                context: context,
                builder: (context) => NewRestockOrderDialog(
                      repo: repo,
                      order: order,
                      editingEnabled: false,
                    ))),
      ];
    }
    var attentionLevel = OverviewAttentionLevel.grey;
    if (order.dateReceived == null) {
      attentionLevel = OverviewAttentionLevel.yellow;
      actions.add(OverviewAction(
          title: "Mark Received",
          onPress: () async {
            await repo.markRestockAsReceived(order);
          }));
    }
    return OverviewTile(
      attentionLevel: attentionLevel,
      title: "Order created on ${order.dateCreated}",
      icon: Icons.receipt,
      actions: actions,
    );
  }
}
