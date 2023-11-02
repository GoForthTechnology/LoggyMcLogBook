import 'package:flutter/material.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/overview_tile.dart';

class OverviewScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Overview'),
      ),
      //drawer: const DrawerWidget(),
      body: NavigationRailScreen(item: NavigationItem.HOME, content: ListView(
        children: [
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.RED,
            title: "Invoice #010101 Past Due",
            subtitle: "Jane Doe was billed 40 days ago",
            icon: Icons.receipt_long,
            actions: [
              OverviewAction(title: "View Invoice")
            ],
          ),
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.YELLOW,
            title: "Client Reminder: Jane Doe",
            subtitle: "Reach out after baby is born around August 1",
            icon: Icons.contacts,
          ),
          OverviewTile(
            title: "Upcoming Appointment",
            subtitle: "FUP 2 for Jane Doe on August 10",
            attentionLevel: OverviewAttentionLevel.GREY,
            icon: Icons.event,
          ),
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.GREY,
            title: "Recent Inquiries",
            subtitle: "Last Week: 0 Last Month: 4",
            icon: Icons.contact_support,
            onClick: () => {},
            actions: [
              OverviewAction(title: "View All"),
              OverviewAction(title: "Add New"),
            ],
          )
        ],
      ),
    ));
  }
}
