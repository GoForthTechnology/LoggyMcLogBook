
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/stream_widget.dart';
import 'package:provider/provider.dart';

class InvoicesSummaryModel extends WidgetModel<InvoicesSummaryState> {

  InvoicesSummaryModel(Client client, Invoices invoiceRepo) {
    invoiceRepo
        .stream((i) => i.clientId == client.id)
        .map((invoices) => createState(client, invoices))
        .listen((state) => updateState(state));
  }

  @override
  InvoicesSummaryState initialState() {
    return InvoicesSummaryState();
  }

  InvoicesSummaryState createState(Client client, List<Invoice> invoices) {
    List<Invoice> pending = [];
    List<Invoice> receivable = [];
    invoices.forEach((invoice) {
      if (invoice.datePaid != null) {
        return;
      }
      if (invoice.dateBilled != null) {
        receivable.add(invoice);
      } else {
        pending.add(invoice);
      }
    });
    return InvoicesSummaryState(
      client: client,
      numInvoices: invoices.length,
      numPendingInvoices: pending.length,
      pendingInvoiceId: pending.isEmpty ? null : pending.first.id,
      numReceivableInvoices: receivable.length,
      receivableInvoiceId: receivable.isEmpty ? null : receivable.first.id,
    );
  }
}

class InvoicesSummaryState {
  final Client? client;

  final int numInvoices;
  final int numPendingInvoices;
  final String? pendingInvoiceId;
  final int numReceivableInvoices;
  final String? receivableInvoiceId;

  InvoicesSummaryState({
    this.client,
    this.numInvoices = 0,
    this.numPendingInvoices = 0,
    this.pendingInvoiceId,
    this.numReceivableInvoices = 0,
    this.receivableInvoiceId,
  });
}

class InvoicesSummaryWidget extends StreamWidget<InvoicesSummaryModel, InvoicesSummaryState> {

  static Widget create(Client client) {
    return Consumer<Invoices>(builder: (context, invoices, child) {
      return ChangeNotifierProvider(create: (_) => InvoicesSummaryModel(client, invoices), builder: (context, child) {
        return InvoicesSummaryWidget();
      });
    });
  }

  @override
  Widget render(BuildContext context, InvoicesSummaryState state, InvoicesSummaryModel model) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Container(
        margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
        child: Text("Invoice Summary", style: Theme.of(context).textTheme.titleMedium),
      ),
      _buildNumInvoices(context, state.numPendingInvoices, state.pendingInvoiceId, "Pending", state.client),
      _buildNumInvoices(context, state.numReceivableInvoices, state.receivableInvoiceId, "Receivable", state.client),
      _buildNumInvoices(context, state.numInvoices, null, "(Total)", state.client),
    ]);
  }

  Widget _buildNumInvoices(
      BuildContext context, int numInvoices, String? invoiceId, String title, Client? client) {
    PageRouteInfo route;
    if (numInvoices == 1) {
      route = InvoiceDetailScreenRoute(invoiceId: invoiceId, clientId: client?.id);
    } else {
      route = InvoicesScreenRoute(client: client);
    }

    return Row(
      children: [
        _paddedItem(Text(
            "# of Invoices $title: ${numInvoices == 0 ? "None" : numInvoices}")),
       numInvoices == 0 ? Container() : TextButton(
        child: Text("View"),
        onPressed: () {
          AutoRouter.of(context).push(route);
        }),
      ],
    );
  }

  Widget _paddedItem(Widget child) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0), child: child);
  }
}