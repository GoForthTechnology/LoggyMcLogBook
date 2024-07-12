import 'package:flutter/material.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/navigation_rail.dart';

class MaterialsOverviewScreen extends StatelessWidget {
  const MaterialsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationRailScreen(
        item: NavigationItem.materials,
        title: Text('Materials'),
        content: Column(
          children: [
            CurrentInventoryPanel(),
            RestockOrdersPanel(),
            ClientOrdersPanel(),
          ],
        ));
  }
}

class CurrentInventoryPanel extends StatelessWidget {
  const CurrentInventoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableInfoPanel(
        title: "Current Inventory", subtitle: "", contents: [Placeholder()]);
  }
}

class RestockOrdersPanel extends StatelessWidget {
  const RestockOrdersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableInfoPanel(
        title: "Restock Orders", subtitle: "", contents: [Placeholder()]);
  }
}

class ClientOrdersPanel extends StatelessWidget {
  const ClientOrdersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandableInfoPanel(
        title: "Client Orders", subtitle: "", contents: [Placeholder()]);
  }
}
