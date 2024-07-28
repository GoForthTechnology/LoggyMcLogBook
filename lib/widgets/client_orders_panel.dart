import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/repos/materials.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/new_material_client_order_dialog.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class ClientOrdersPanel extends StatelessWidget {
  final String title;
  final String? clientID;

  const ClientOrdersPanel({super.key, required this.title, this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MaterialsRepo, Invoices>(
        builder: (context, repo, invoiceRepo, child) =>
            StreamBuilder<List<ClientOrder>>(
                stream: repo.clientOrders(clientID: clientID),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  var orders = snapshot.data!;
                  var numOutstanding =
                      orders.where((o) => o.dateShipped == null).length;
                  var numToInvoice = orders
                      .where(
                          (o) => o.dateShipped != null && o.invoiceID == null)
                      .length;
                  return ExpandableInfoPanel(
                    title: title,
                    subtitle:
                        "$numOutstanding order(s) to ship, $numToInvoice order(s) to invoice",
                    contents: orders
                        .map((o) => _orderTile(context, repo, invoiceRepo, o))
                        .toList(),
                  );
                }));
  }

  Widget _orderTile(BuildContext context, MaterialsRepo repo,
      Invoices invoiceRepo, ClientOrder order) {
    List<OverviewAction> actions = [];
    var attentionLevel = OverviewAttentionLevel.grey;
    if (order.dateShipped == null) {
      attentionLevel = OverviewAttentionLevel.yellow;
      actions.add(OverviewAction(
          title: "Mark Shipped",
          onPress: () async {
            await repo.markClientOrderAsShipped(order);
          }));
      actions.add(OverviewAction(
          title: "Edit",
          onPress: () => showDialog(
              context: context,
              builder: (context) => NewClientOrderDialog(
                    clientID: order.clientID,
                    repo: repo,
                    order: order,
                    editingEnabled: true,
                  ))));
    } else {
      actions.add(OverviewAction(
          title: "View",
          onPress: () => showDialog(
              context: context,
              builder: (context) => NewClientOrderDialog(
                    clientID: order.clientID,
                    repo: repo,
                    order: order,
                    editingEnabled: false,
                  ))));
    }
    if (order.dateShipped != null && order.invoiceID == null) {
      attentionLevel = OverviewAttentionLevel.yellow;
      actions.add(OverviewAction(
          title: "Invoice",
          onPress: () async {
            var messenger = ScaffoldMessenger.of(context);
            var message = await invoiceRepo.invoiceClientOrder(order);
            messenger.showSnackBar(SnackBar(content: Text(message)));
          }));
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
