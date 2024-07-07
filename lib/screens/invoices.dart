import 'package:flutter/material.dart';
import 'package:lmlb/widgets/invoice_list.dart';
import 'package:lmlb/widgets/navigation_rail.dart';

class InvoicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationRailScreen(
      item: NavigationItem.BILLING,
      title: const Text('Billing'),
      content: InvoiceListWidget(),
    );
  }
}
