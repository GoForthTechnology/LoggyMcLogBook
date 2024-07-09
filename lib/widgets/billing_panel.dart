import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class BillingPanel extends StatelessWidget {
  final String clientID;

  const BillingPanel({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Invoices>(
      builder: (context, repo, child) => StreamBuilder<List<Invoice>>(
          stream: repo.list(clientID: clientID),
          builder: (context, snapshot) {
            List<Invoice> invoices = snapshot.data ?? [];
            List<Invoice> sortedInvoices = List.from(invoices);
            sortedInvoices
                .sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
            List<Widget> contents = [
              ...sortedInvoices
                  .map((i) => InvoiceTile(invoice: i))
                  .toList(growable: true),
              PriceWidget(
                clientID: clientID,
              ),
            ];
            return ExpandableInfoPanel(
              title: "Billing",
              subtitle: _subtitle(sortedInvoices),
              initiallyExpanded: false,
              contents: contents,
            );
          }),
    );
  }

  String _subtitle(List<Invoice> invoices) {
    int numPending = invoices.where((i) => i.dateBilled == null).length;
    int numOutstanding = invoices
        .where((i) => i.dateBilled != null && i.datePaid == null)
        .length;
    return "$numPending pending, $numOutstanding outstanding";
  }
}

class InvoiceTile extends StatelessWidget {
  final Invoice invoice;

  const InvoiceTile({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return OverviewTile(
      attentionLevel: OverviewAttentionLevel.GREY,
      title: "Invoice #${invoice.invoiceNumStr()}",
      icon: Icons.receipt_long,
      actions: [
        OverviewAction(
            title: "VIEW",
            onPress: () {
              AutoRouter.of(context).push(InvoiceDetailScreenRoute(
                  invoiceID: invoice.id!, clientID: invoice.clientID));
            })
      ],
    );
  }
}

class PriceWidget extends StatefulWidget {
  final String clientID;

  const PriceWidget({super.key, required this.clientID});

  @override
  State<PriceWidget> createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  final TextEditingController priceController = TextEditingController();
  Currency? currency;

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
      builder: (context, repo, child) => StreamBuilder<Client?>(
        stream: repo.stream(widget.clientID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var client = snapshot.data!;
          if (priceController.text.isEmpty) {
            priceController.text =
                client.defaultFollowUpPrice?.toString() ?? "";
          }
          if (currency == null) {
            currency = client.currency;
          }
          return Row(children: [
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  "Default Follow Up Price:",
                  style: Theme.of(context).textTheme.titleMedium,
                )),
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: 60),
              child: TextFormField(
                style: Theme.of(context).textTheme.titleMedium,
                controller: priceController,
              ),
            ),
            DropdownButton<Currency>(
              items: Currency.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      ))
                  .toList(),
              value: currency,
              onChanged: (c) => setState(() {
                currency = c;
              }),
            ),
            TextButton(
              onPressed: () async {
                var updatedClient = client.copyWith(
                    currency: currency,
                    defaultFollowUpPrice: int.parse(priceController.text));
                await repo.update(updatedClient);
                const snackBar =
                    SnackBar(content: Text("Billing info updated"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text("SAVE"),
            ),
          ]);
        },
      ),
    );
  }
}
