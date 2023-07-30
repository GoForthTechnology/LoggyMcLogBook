import 'package:flutter/material.dart';
import 'package:lmlb/widgets/appointment_overview/appointment_overview_widget.dart';
import 'package:lmlb/widgets/drawer.dart';

class OverviewScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Overview'),
      ),
      drawer: const DrawerWidget(),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints.tightFor(width: 600), child: GridView.extent(
        primary: false,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        maxCrossAxisExtent: 300.0,
        children: <Widget>[
          AppointmentOverviewWidget(),
        ],
      ))),
    );
  }
}
