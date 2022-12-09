import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:provider/provider.dart';


class InvoicesScreen extends StatelessWidget {
  final Client? client;

  const InvoicesScreen({Key? key, this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasClientFilter = client != null;
    return Scaffold(
      appBar: AppBar(
        title: !hasClientFilter ? const Text('Invoices') : Text("${client!.fullName()}'s Invoices"),
      ),
      body: Consumer2<Invoices, Clients>(
          builder: (context, invoiceRepo, clientsModel, child) {
        final invoices = invoiceRepo.get(sorted: true, clientId: client?.id);
        return ListView.builder(
            itemCount: invoices.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return FutureBuilder<Client?>(
                future: clientsModel.get(invoice.clientId),
                builder: (context, snapshot) => InvoiceTile(
                  invoice,
                  snapshot.data!,
                  hasClientFilter,
                )
              );
            });
      }),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () => addInvoice(context),
      ),
    );
  }

  void addInvoice(BuildContext context) {
    AutoRouter.of(context).push(InvoiceInfoScreenRoute()).then((updated) {
      if (updated != null && updated as bool) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Invoice added')));
      }
    });
  }
}

class InvoiceTile extends StatelessWidget {
  final Invoice invoice;
  final Client client;
  final bool hasClientFilter;

  InvoiceTile(
    this.invoice,
    this.client,
    this.hasClientFilter,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          /*backgroundColor: Colors
              .primaries[invoice.id! % Colors.primaries.length],*/
        ),
        title: Text(
          hasClientFilter
              ? "Invoice #${invoice.invoiceNumStr()}"
              : "${client.fullName()} Invoice #${invoice.invoiceNumStr()}",
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            confirmDeletion(context, invoice);
          },
        ),
        onTap: () {
          AutoRouter.of(context).push(InvoiceInfoScreenRoute(invoice:  invoice)).then((result) {
            if (result != null && result as bool) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Client updated')));
            }
          });
        },
      ),
    );
  }

  void confirmDeletion(BuildContext context, Invoice invoice) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
        Provider.of<Invoices>(context, listen: false)
            .remove(invoice)
            .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed client.'),
              duration: Duration(seconds: 1),
            ),
          );
        });
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm Deletion"),
      content: Text("Would you like to remove ${client.fullName()}?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
