import 'package:flutter/material.dart';
import 'package:lmlb/widgets/invoice_list.dart';
import 'package:lmlb/widgets/navigation_rail.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationRailScreen(
      item: NavigationItem.BILLING,
      title: Text('Billing'),
      content: InvoiceListWidget(),
    );
  }
}
