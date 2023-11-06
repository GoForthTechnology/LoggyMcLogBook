import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/routes.gr.dart';

enum NavigationItem {
  HOME(label: "Home", icon: Icons.home, route: OverviewScreenRoute()),
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
  final Widget title;
  final Widget? fab;
  final Widget content;

  const NavigationRailScreen({super.key, required this.item, required this.content, required this.title, this.fab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      body: _showRail(context) ? _railLayout(context) : content,
      floatingActionButton: fab,
      bottomNavigationBar: _bottomNavBar(context),
    );
  }

  bool _showRail(BuildContext context) {
    return MediaQuery.of(context).size.width >= 640;
  }

  Widget _railLayout(BuildContext context) {
    return Row(children: [
      NavigationRail(
        selectedIndex: item.index,
        destinations: NavigationItem.values.map((i) => NavigationRailDestination(
          icon: Icon(i.icon),
          label: Text(i.label),
        )).toList(),
        onDestinationSelected: (index) => _onSelect(context, index),
      ),
      Expanded(child: content),
    ],);
  }

  Widget? _bottomNavBar(BuildContext context) {
    if (_showRail(context)) {
      return null;
    }
    return NavigationBar(
      onDestinationSelected: (index) => _onSelect(context, index),
      destinations: NavigationItem.values
          .map((i) => NavigationDestination(icon: Icon(i.icon), label: i.label))
          .toList(),
    );
  }

  void _onSelect(BuildContext context, int index) {
    var item = NavigationItem.values[index];
    if (item.route != null) {
      AutoRouter.of(context).popAndPush(item.route!);
    }
  }
}