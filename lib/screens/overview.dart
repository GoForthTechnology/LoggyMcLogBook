import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/screens/appointments.dart';
import 'package:provider/provider.dart';

class OverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
      ),
      body: Row(
        children: [
          Expanded(
              flex: 1,
              child: Column(
                children: [
                  clientOverview(context),
                  appointmentOverview(context),
                  invoiceOverview(context),
                ],
              )),
        ],
      ),
    );
  }

  Widget invoiceOverview(BuildContext context) {
    return overviewContainer(context, "Invoice Overview", InvoicesScreenRoute(),
        Consumer<Invoices>(builder: (context, model, child) {
      final numPending = model.getPending().length;
      final numReceivable = model.getReceivable().length;
      final numPaid = model.getPaid().length;
      return Column(
        children: [
          Text("Num Drafts: $numPending", style: redIfPositive(numPending)),
          Text("Num Receivable: $numReceivable",
              style: redIfPositive(numReceivable)),
          Text("Num Paid: $numPaid", style: redIfPositive(numPaid)),
        ],
      );
    }));
  }

  TextStyle redIfPositive(int num) {
    return TextStyle(color: num > 0 ? Colors.red : Colors.black);
  }

  Widget clientOverview(BuildContext context) {
    return overviewContainer(
        context,
        "Client Overview",
        ClientsScreenRoute(),
        Consumer<Clients>(
            builder: (context, model, child) =>
                Text("Num Clients: ${model.getAll().length}")));
  }

  Widget appointmentOverview(BuildContext context) {
    return overviewContainer(
        context,
        "Appointment Overview",
        AppointmentsScreenRoute(view: View.ALL.name),
        Consumer<Appointments>(builder: (context, model, child) {
      final numPending = model.getPending().length;
      return Column(
        children: [
          Text("Num Upcoming: ${model.getUpcoming().length}"),
          Text("Num to Bill: $numPending",
              style:
                  TextStyle(color: numPending > 0 ? Colors.red : Colors.black)),
        ],
      );
    }));
  }

  Widget overviewContainer(BuildContext context, String title, PageRouteInfo route, Widget contents) {
    return Center(
        child: GestureDetector(
          onTap: () => AutoRouter.of(context).push(route),
      child: Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 5.0,
                offset: Offset(0.0, 0.75))
          ],
        ),
        child: Column(children: [
          Text(title, style: Theme.of(context).textTheme.subtitle1),
          Container(margin: EdgeInsets.only(top: 10.0), child: contents),
        ]),
      ),
    ));
  }
}
