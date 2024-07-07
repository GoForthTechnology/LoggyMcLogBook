import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/widgets/navigation_rail.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceID;
  final String clientID;

  const InvoiceDetailScreen(
      {super.key,
      @PathParam() required this.invoiceID,
      @PathParam() required this.clientID});

  @override
  Widget build(BuildContext context) {
    return NavigationRailScreen(
      item: NavigationItem.BILLING,
      content: const Placeholder(),
      title: Text("Invoice Details"),
    );
  }
}
