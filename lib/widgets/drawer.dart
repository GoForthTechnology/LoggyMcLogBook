import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/routes.gr.dart';

class DrawerWidget extends StatelessWidget {

  const DrawerWidget();

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Your Logbook',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text('Inquiries'),
              leading: Icon(Icons.contact_support),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Clients'),
              leading: Icon(Icons.contacts),
              onTap: () {
                AutoRouter.of(context).push(ClientsScreenRoute());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Appointments'),
              leading: Icon(Icons.event),
              onTap: () {
                AutoRouter.of(context).push(AppointmentsScreenRoute());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Billing'),
              leading: Icon(Icons.receipt_long),
              onTap: () => showComingSoon(context),
            ),
            ListTile(
              title: const Text('Materials'),
              leading: Icon(Icons.inventory_2),
              onTap: () => showComingSoon(context),
            ),
          ],
        )
    );
  }

  void showComingSoon(BuildContext context) {
    var snackBar = SnackBar(content: Text("Coming Soon!"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.pop(context);
  }
}