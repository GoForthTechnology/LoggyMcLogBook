import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/routes.gr.dart';

enum NavigationItem {
  HOME(label: "Home", icon: Icons.home, route: OverviewScreenRoute()),
  INQUIRIES(label: "Inquiries", icon: Icons.contact_support),
  CLIENTS(label: "Clients", icon: Icons.contacts, route: ClientsScreenRoute()),
  APPOINTMENTS(label: "Appointments", icon: Icons.event, route: AppointmentsScreenRoute()),
  BILLING(label: "Billing", icon: Icons.receipt_long),
  MATERIALS(label: "Materials", icon: Icons.inventory_2),
  ;

  final String label;
  final IconData icon;
  final PageRouteInfo? route;

  const NavigationItem({required this.label, required this.icon, this.route});
}

class NavigationRailScreen extends StatelessWidget {
  final NavigationItem item;
  final Widget content;

  const NavigationRailScreen({super.key, required this.item, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      NavigationRail(
        selectedIndex: item.index,
        destinations: NavigationItem.values.map((i) => NavigationRailDestination(
          icon: Icon(i.icon),
          label: Text(i.label),
        )).toList(),
        onDestinationSelected: ((index) {
          var item = NavigationItem.values[index];
          if (item.route != null) {
            AutoRouter.of(context).push(item.route!);
          }
        }),
      ),
      Expanded(child: content),
    ],);
  }
}