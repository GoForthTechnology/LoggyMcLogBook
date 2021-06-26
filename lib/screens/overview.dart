import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/screens/appointments.dart';
import 'package:lmlb/screens/clients.dart';

class OverviewScreen extends StatelessWidget {
  static const routeName = '/overview';

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
                ],
              )),
        ],
      ),
    );
  }

  Widget clientOverview(BuildContext context, {height: 100}) {
    return overviewContainer(
        context,
        "Client Overview",
        ClientsScreen.routeName,
        null,
        Consumer<Clients>(
            builder: (context, model, child) =>
                Text("Num Clients: ${model.getAll().length}")));
  }

  Widget appointmentOverview(BuildContext context) {
    return overviewContainer(
        context,
        "Appointment Overview",
        AppointmentsScreen.routeName,
        AppointmentsScreenArguments(null, View.ALL),
        Consumer<Appointments>(
            builder: (context, model, child) =>
                Text("Num Upcoming: ${model.getUpcoming().length}")));
  }

  Widget overviewContainer(
      BuildContext context, String title, String routeName, Object? args, Widget contents) {
    return Center(
        child: GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(routeName, arguments: args),
      child: Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 5.0,
                offset: Offset(0.0, 0.75)
            )
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
