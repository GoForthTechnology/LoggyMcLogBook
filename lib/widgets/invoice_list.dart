import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/filter_bar.dart';
import 'package:provider/provider.dart';

class InvoiceListWidget extends StatelessWidget {
  const InvoiceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<Invoices, Clients>(
        builder: (context, invoices, clientRepo, child) =>
            StreamBuilder<List<Client>>(
                stream: clientRepo.streamAll(),
                builder: (context, snapshot) {
                  Map<String, Client> clients = {};
                  if (snapshot.hasData) {
                    snapshot.data!.forEach((c) {
                      clients[c.id!] = c;
                    });
                  }
                  return FilterableListView<Invoice>(
                    itemStream: invoices.list(),
                    filters: [],
                    additionalSortingOptions: [],
                    defaultSort: Sort<Invoice>(
                        label: 'By Date Created',
                        comparator: (a, b) =>
                            a.dateCreated.compareTo(b.dateCreated)),
                    buildTile: (i) => InvoiceTile(
                        invoice: InvoiceData.fromInvoice(clients, i)),
                  );
                }));
  }
}

class InvoiceData {
  final String clientName;
  final String invoiceNumStr;
  final String invoiceID;
  final String clientID;

  InvoiceData(
      {required this.clientName,
      required this.invoiceID,
      required this.invoiceNumStr,
      required this.clientID});

  static InvoiceData fromInvoice(
      Map<String, Client> clientIndex, Invoice invoice) {
    Client? client = clientIndex[invoice.clientID];

    return InvoiceData(
        clientName: client?.fullName() ?? "",
        invoiceID: invoice.id!,
        invoiceNumStr: invoice.invoiceNumStr(),
        clientID: invoice.clientID);
  }
}

class InvoiceTile extends StatelessWidget {
  final InvoiceData invoice;

  const InvoiceTile({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          // TODO: vary this by status of invoice
          backgroundColor: Colors.blue,
        ),
        title:
            Text("Invoice #${invoice.invoiceNumStr} for ${invoice.clientName}"),
        //trailing: WarningWidget(warnings: []),
        onTap: () => AutoRouter.of(context).push(InvoiceDetailScreenRoute(
            invoiceID: invoice.invoiceID, clientID: invoice.clientID)),
      ),
    ));
  }
}
