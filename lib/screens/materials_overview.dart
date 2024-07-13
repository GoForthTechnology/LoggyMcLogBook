import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/materials.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/new_material_item_dialog.dart';
import 'package:lmlb/widgets/new_material_order_dialog.dart';
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
                      RestockOrdersPanel(repo: repo),
                      ClientOrdersPanel(repo: repo),
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
                          builder: (context) =>
                              NewMaterialOrderDialog(repo: repo),
                        ),
                    icon: const Icon(Icons.add))),
            contents: orders.map((o) => _orderTile(context, o)).toList(),
          );
        });
  }

  Widget _orderTile(BuildContext context, RestockOrder order) {
    List<OverviewAction> actions = [
      OverviewAction(
          title: "Edit",
          onPress: () => showDialog(
              context: context,
              builder: (context) =>
                  NewMaterialOrderDialog(repo: repo, order: order))),
    ];
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

class ClientOrdersPanel extends StatelessWidget {
  final MaterialsRepo repo;

  const ClientOrdersPanel({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClientOrder>>(
        stream: repo.clientOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var orders = snapshot.data!;
          var numOutstanding =
              orders.where((o) => o.dateShipped == null).length;
          return ExpandableInfoPanel(
            title: "Client Orders",
            subtitle: "$numOutstanding order(s) to ship",
            trailing: Tooltip(
                message: "Add New Order",
                child: IconButton(
                    onPressed: () => showDialog(
                          context: context,
                          builder: (context) =>
                              NewMaterialOrderDialog(repo: repo),
                        ),
                    icon: const Icon(Icons.add))),
            contents: orders.map((o) => _orderTile(context, o)).toList(),
          );
        });
  }

  Widget _orderTile(BuildContext context, ClientOrder order) {
    List<OverviewAction> actions = [];
    var attentionLevel = OverviewAttentionLevel.grey;
    if (order.dateShipped == null) {
      attentionLevel = OverviewAttentionLevel.yellow;
      actions.add(OverviewAction(title: "Mark Shipped", onPress: () {}));
    }
    return Consumer<Clients>(
      builder: (context, clients, child) => FutureBuilder<Client?>(
        future: clients.get(order.clientID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var client = snapshot.data!;
          return OverviewTile(
            attentionLevel: attentionLevel,
            title:
                "Order for ${client.fullName()} created on ${order.dateCreated}",
            icon: Icons.receipt,
            actions: actions,
          );
        },
      ),
    );
  }
}
