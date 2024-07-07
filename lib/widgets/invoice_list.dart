import 'package:flutter/material.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/widgets/filter_bar.dart';
import 'package:provider/provider.dart';

class InvoiceListWidget extends StatelessWidget {
  const InvoiceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Invoices>(
        builder: (context, invoices, child) => FilterableListView<Invoice>(
              itemStream: invoices.list(),
              filters: [],
              additionalSortingOptions: [],
              defaultSort: Sort<Invoice>(
                  label: 'By Date Created',
                  comparator: (a, b) => a.dateCreated.compareTo(b.dateCreated)),
              buildTile: (i) => InvoiceTile(invoice: i),
            ));
  }
}

class InvoiceTile extends StatelessWidget {
  final Invoice invoice;

  const InvoiceTile({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
