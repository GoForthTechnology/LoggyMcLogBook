

import 'package:flutter/material.dart';
import 'package:lmlb/widgets/overview_tile.dart';

class ClientOverviewWidget extends StatelessWidget {

  const ClientOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return OverviewTile(
      attentionLevel: OverviewAttentionLevel.YELLOW,
      title: "Client Reminder: Jane Doe",
      subtitle: "Reach out after baby is born around August 1",
      icon: Icons.contacts,
      onClick: () => {},
    );
  }
}

class AppointmentOverviewModel extends ChangeNotifier {

}