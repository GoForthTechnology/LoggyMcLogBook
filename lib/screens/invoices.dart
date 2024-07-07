import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/appointment_list/appointment_list_model.dart';
import 'package:lmlb/widgets/appointment_list/appointment_list_widget.dart';
import 'package:lmlb/widgets/invoice_list.dart';
import 'package:lmlb/widgets/navigation_rail.dart';

class InvoicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppointmentListModel.provide(
      clientFilter: null,
      onClientTapped: (context, invoiceID, clientID) {
        AutoRouter.of(context)
            .push(InvoiceDetailScreenRoute(
                invoiceID: invoiceID, clientID: clientID))
            .then((result) {
          if (result != null && result as bool) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('Client updated')));
          }
        });
      },
      child: NavigationRailScreen(
        item: NavigationItem.BILLING,
        title: const Text('Billing'),
        content: InvoiceListWidget(),
      ),
    );
  }

  Widget? buildFab(BuildContext context) {
    return FloatingActionButton(
      // isExtended: true,
      child: Icon(Icons.add),
      backgroundColor: Colors.green,
      // TODO: Re-enable
      //onPressed: () => addAppointment(context),
      onPressed: () {},
    );
  }
}
