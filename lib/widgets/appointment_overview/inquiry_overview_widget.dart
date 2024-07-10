import 'package:flutter/material.dart';
import 'package:lmlb/widgets/overview_tile.dart';

class InquiryOverviewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverviewTile(
      attentionLevel: OverviewAttentionLevel.grey,
      title: "Recent Inquiries",
      subtitle: "Last Week: 0 Last Month: 4",
      icon: Icons.contact_support,
      onClick: () => {},
      actions: [
        OverviewAction(title: "View All"),
        OverviewAction(title: "Add New"),
      ],
    );
  }
}

class AppointmentOverviewModel extends ChangeNotifier {}
