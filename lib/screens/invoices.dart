import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/screens/appointment_info.dart';
import 'package:provider/provider.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/screens/client_info.dart';


class InvoicesScreenArguments {
  final Client? client;

  InvoicesScreenArguments(this.client);
}

class InvoicesScreen extends StatelessWidget {
  static const routeName = '/invoices';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as InvoicesScreenArguments;
    final hasClientFilter = args.client != null;
    return Scaffold(
      appBar: AppBar(
        title: !hasClientFilter ? const Text('Invoices') : Text("${args.client!.fullName()}'s Invoices"),
      ),
      body: Consumer2<Invoices, Clients>(
          builder: (context, invoiceRepo, clientsModel, child) {
        final invoices = invoiceRepo.get(sorted: true, clientId: args.client?.num);
        return ListView.builder(
            itemCount: invoices.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return InvoiceTile(
                invoice,
                clientsModel.get(invoice.clientId)!,
                hasClientFilter,
              );
            });
      }),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () => addAppointment(context),
      ),
    );
  }

  void addAppointment(BuildContext context) {
    Navigator.of(context)
        .pushNamed(AppointmentInfoScreen.routeName,
            arguments: AppointmentInfoScreenArguments(null))
        .then((updated) {
      if (updated as bool) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Appointment added')));
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
          backgroundColor: Colors
              .primaries[invoice.id! % Colors.primaries.length],
        ),
        title: Text(
          hasClientFilter
              ? "Invoice #${invoice.invoiceNumStr()}"
              : '${client.fullName()} "Invoice #${invoice.invoiceNumStr()}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            //confirmDeletion(context, appointment);
          },
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed(ClientInfoScreen.routeName,
                  arguments: ClientInfoScreenArguments(client))
              .then((result) {
            if (result as bool) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Client updated')));
            }
          });
        },
      ),
    );
  }

  /*void confirmDeletion(BuildContext context, Appointment appointment) {
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
            .remove(appointment)
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
  }*/
}
