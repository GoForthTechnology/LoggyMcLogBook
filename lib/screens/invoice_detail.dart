import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceID;
  final String clientID;

  const InvoiceDetailScreen(
      {super.key,
      @PathParam() required this.invoiceID,
      @PathParam() required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Invoices>(
      builder: (context, repo, child) => StreamBuilder<Invoice?>(
        stream: repo.get(clientID: clientID, invoiceID: invoiceID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var invoice = snapshot.data;
          if (invoice == null) {
            throw Exception("Invoice not found!");
          }
          return NavigationRailScreen(
            item: NavigationItem.BILLING,
            title: const Text("Invoice Details"),
            content: Column(
              children: [
                DatePanel(
                  invoice: invoice,
                  invoiceRepo: repo,
                ),
                AppointmentPanel(
                  invoice: invoice,
                  invoiceRepo: repo,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DatePanel extends StatefulWidget {
  final Invoice invoice;
  final Invoices invoiceRepo;

  const DatePanel(
      {super.key, required this.invoice, required this.invoiceRepo});

  @override
  State<DatePanel> createState() => _DatePanelState();
}

class _DatePanelState extends State<DatePanel> {
  DateTime? dateBilled;
  var dateBilledController = TextEditingController();

  DateTime? datePaid;
  var datePaidController = TextEditingController();

  @override
  void initState() {
    dateBilled = widget.invoice.dateBilled;
    dateBilledController.text =
        widget.invoice.dateBilled?.toIso8601String() ?? "";

    datePaid = widget.invoice.datePaid;
    datePaidController.text = widget.invoice.datePaid?.toIso8601String() ?? "";

    super.initState();
  }

  void updateDateBilled(DateTime? value) async {
    await widget.invoiceRepo.update(
        widget.invoice.copyWith(dateBilled: dateBilled, datePaid: datePaid));
    setState(() {
      dateBilled = value;
      dateBilledController.text = value?.toIso8601String() ?? "";
    });
  }

  void updateDatePaid(DateTime? value) async {
    await widget.invoiceRepo.update(
        widget.invoice.copyWith(dateBilled: dateBilled, datePaid: datePaid));
    setState(() {
      datePaid = value;
      datePaidController.text = value?.toIso8601String() ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
            child: TextFormField(
          decoration: const InputDecoration(label: Text("Date Created")),
          initialValue: widget.invoice.dateCreated.toIso8601String(),
          enabled: false,
        )),
        Flexible(
            child: TextFormField(
          decoration: InputDecoration(
              label: const Text("Date Billed"),
              suffixIcon: dateBilled == null
                  ? null
                  : IconButton(
                      onPressed: () => updateDateBilled(null),
                      icon: const Icon(Icons.clear))),
          controller: dateBilledController,
          onTap: () async {
            updateDateBilled(await promptForDate(initialDate: dateBilled));
          },
        )),
        Flexible(
            child: TextFormField(
          decoration: InputDecoration(
              label: const Text("Date Paid"),
              suffixIcon: datePaid == null
                  ? null
                  : IconButton(
                      onPressed: () => updateDatePaid(null),
                      icon: const Icon(Icons.clear))),
          controller: datePaidController,
          onTap: () async {
            if (dateBilled == null) {
              promptForNotBilled();
              return;
            }
            updateDatePaid(await promptForDate(initialDate: datePaid));
          },
        )),
      ],
    );
  }

  void promptForNotBilled() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Not yet billed"),
        content: const Text(
            "The invoice must first be billed before it can be paid."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Dismiss"))
        ],
      ),
    );
  }

  Future<DateTime?> promptForDate({DateTime? initialDate}) {
    return showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: initialDate ?? DateTime.now());
  }
}

class AppointmentPanel extends StatelessWidget {
  final Invoice invoice;
  final Invoices invoiceRepo;

  const AppointmentPanel(
      {super.key, required this.invoice, required this.invoiceRepo});

  @override
  Widget build(BuildContext context) {
    int totalPrice = invoice.appointmentEntries
        .map((e) => e.price)
        .reduce((value, element) => value + element);
    return ExpandableInfoPanel(
      title: "Appointments",
      subtitle: "$totalPrice ${invoice.currency.name}",
      contents: invoice.appointmentEntries
          .map((e) => OverviewTile(
                attentionLevel: OverviewAttentionLevel.GREY,
                title:
                    "${e.price} ${invoice.currency.name} for ${e.appointmentType.name} on ${e.appointmentDate}",
                icon: Icons.event,
                additionalTrailing: [
                  IconButton(
                    onPressed: () async {
                      if (await confirmAppointmentRemoval(context)) {
                        await invoiceRepo.removeAppointment(
                            invoice, e.appointmentID);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  )
                ],
              ))
          .toList(),
    );
  }

  Future<bool> confirmAppointmentRemoval(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Removal"),
            content: const Text(
                "Would you like to remove this appointment from the invoice?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No")),
            ],
          ),
        ) ??
        false;
  }
}
