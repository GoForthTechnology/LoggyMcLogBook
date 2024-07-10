import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/routes.gr.dart';

enum NavigationItem {
  home(label: "Home", icon: Icons.home, route: OverviewScreenRoute()),
  clients(label: "Clients", icon: Icons.contacts, route: ClientsScreenRoute()),
  appointments(
      label: "Appointments",
      icon: Icons.event,
      route: AppointmentsScreenRoute()),
  billing(
      label: "Billing", icon: Icons.receipt_long, route: InvoicesScreenRoute()),
  materials(label: "Materials", icon: Icons.palette),
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

  const NavigationRailScreen(
      {super.key,
      required this.item,
      required this.content,
      required this.title,
      this.fab});

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
    return Row(
      children: [
        NavigationRail(
          selectedIndex: item.index,
          destinations: NavigationItem.values
              .map((i) => NavigationRailDestination(
                    icon: Icon(i.icon),
                    label: Text(i.label),
                  ))
              .toList(),
          onDestinationSelected: (index) => _onSelect(context, index),
        ),
        Expanded(child: content),
      ],
    );
  }

  Widget? _bottomNavBar(BuildContext context) {
    if (_showRail(context)) {
      return null;
    }
    return NavigationBar(
      onDestinationSelected: (index) => _onSelect(context, index),
      selectedIndex: item.index,
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
