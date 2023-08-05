

import 'package:flutter/material.dart';
import 'package:lmlb/widgets/overview_tile.dart';

class InvoiceOverviewWidget extends StatelessWidget {

  final OverviewAttentionLevel attentionLevel;

  const InvoiceOverviewWidget({super.key, required this.attentionLevel});

  @override
  Widget build(BuildContext context) {
    return OverviewTile(
      attentionLevel: this.attentionLevel,
      title: "Invoice #010101 Past Due",
      subtitle: "Jane Doe was billed 40 days ago",
      icon: Icons.receipt_long,
      onClick: () => {},
    );
  }
}

class AppointmentOverviewModel extends ChangeNotifier {

}