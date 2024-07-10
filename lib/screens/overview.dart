import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRailScreen(
      item: NavigationItem.home,
      title: const Text('Your Overview'),
      content: ListView(
        children: const [
          AppointmentOverviewTile(),
          InvoiceOverviewTile(),
        ],
      ),
    );
  }
}

class AppointmentOverviewState {
  final int numUpcoming;
  final int numUnbilled;

  AppointmentOverviewState(
      {required this.numUpcoming, required this.numUnbilled});
}

class AppointmentOverviewTile extends StatelessWidget {
  const AppointmentOverviewTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Appointments>(
      builder: (context, repo, child) =>
          StreamBuilder<AppointmentOverviewState>(
        stream: Rx.combineLatest2<int, int, AppointmentOverviewState>(
            repo
                .streamAll((a) => !a.time.isBefore(DateTime.now()))
                .map((as) => as.length),
            repo
                .streamAll((a) =>
                    !a.time.isAfter(DateTime.now()) && a.invoiceId == null)
                .map((as) => as.length),
            (numUpcoming, numUnbilled) => AppointmentOverviewState(
                  numUnbilled: numUnbilled,
                  numUpcoming: numUpcoming,
                )),
        builder: (context, snapshot) {
          return OverviewTile(
            attentionLevel: OverviewAttentionLevel.grey,
            title: "Appointment Overview",
            icon: Icons.event,
            subtitle:
                "${snapshot.data?.numUpcoming ?? 0} upcoming, ${snapshot.data?.numUnbilled} to bill",
            onClick: () =>
                AutoRouter.of(context).push(const AppointmentsScreenRoute()),
          );
        },
      ),
    );
  }
}

class InvoiceOverviewState {
  final int numPending;
  final int numOutstanding;

  InvoiceOverviewState(
      {required this.numPending, required this.numOutstanding});
}

class InvoiceOverviewTile extends StatelessWidget {
  const InvoiceOverviewTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Invoices>(
      builder: (context, repo, child) => StreamBuilder<InvoiceOverviewState>(
        stream: repo.list().map((invoices) {
          int numPending = 0;
          int numOutstanding = 0;
          for (Invoice i in invoices) {
            switch (i.state) {
              case InvoiceState.pending:
                numPending++;
                break;
              case InvoiceState.billed:
              case InvoiceState.overdue:
                numOutstanding++;
                break;
              case InvoiceState.paid:
                break;
            }
          }
          return InvoiceOverviewState(
              numPending: numPending, numOutstanding: numOutstanding);
        }),
        builder: (context, snapshot) {
          return OverviewTile(
            attentionLevel: OverviewAttentionLevel.grey,
            title: "Billing Overview",
            icon: Icons.receipt_long,
            subtitle:
                "${snapshot.data?.numPending ?? 0} pending, ${snapshot.data?.numOutstanding ?? 0} outstanding",
            onClick: () =>
                AutoRouter.of(context).push(const InvoicesScreenRoute()),
          );
        },
      ),
    );
  }
}
