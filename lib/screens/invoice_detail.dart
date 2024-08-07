import 'package:auto_route/auto_route.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/client_general_info.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/gif_repo.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/repos/materials.dart';
import 'package:lmlb/widgets/gif_form.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/new_material_client_order_dialog.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:lmlb/widgets/rendered_invoice.dart';
import 'package:provider/provider.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:rxdart/rxdart.dart';

class Deps {
  final ClientInfo clientInfo;
  final Invoice? invoice;

  Deps({required this.clientInfo, required this.invoice});
}

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceID;
  final String clientID;

  const InvoiceDetailScreen(
      {super.key,
      @PathParam() required this.invoiceID,
      @PathParam() required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer3<Invoices, Clients, GifRepo>(
      builder: (context, invoiceRepo, clientRepo, gifRepo, child) =>
          StreamBuilder<Deps>(
        stream:
            Rx.combineLatest3<Invoice?, Client?, Map<GifItem, String>, Deps>(
                invoiceRepo.get(clientID: clientID, invoiceID: invoiceID),
                clientRepo.stream(clientID),
                gifRepo.getAll(GeneralInfoItem, clientID),
                (invoice, client, gifItems) {
          return Deps(
              clientInfo: ClientInfo(
                clientDisplayNum: client?.displayNum() ?? "",
                fullName: client?.fullName() ?? "",
                address: gifItems[GeneralInfoItem.ADDRESS] ?? "",
                city: gifItems[GeneralInfoItem.CITY] ?? "",
                state: gifItems[GeneralInfoItem.STATE] ?? "",
                zip: gifItems[GeneralInfoItem.ZIP] ?? "",
                country: gifItems[GeneralInfoItem.COUNTRY] ?? "",
                email: gifItems[GeneralInfoItem.EMAIL] ?? "",
                phoneNumber: gifItems[GeneralInfoItem.PHONE] ?? "",
              ),
              invoice: invoice);
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var invoice = snapshot.data?.invoice;
          if (invoice == null) {
            throw Exception("Invoice not found!");
          }
          return NavigationRailScreen(
            item: NavigationItem.billing,
            title: const Text("Invoice Details"),
            content: Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    DatePanel(
                      invoice: invoice,
                      invoiceRepo: invoiceRepo,
                    ),
                    ClientInfoPanel(clientID: clientID),
                    AppointmentPanel(
                        invoice: invoice, invoiceRepo: invoiceRepo),
                    MaterialsPanel(invoice: invoice, invoiceRepo: invoiceRepo),
                    if (invoice.dateBilled != null)
                      InoviceRenderPanel(
                        invoice: invoice,
                        clientInfo: snapshot.data!.clientInfo,
                      ),
                  ],
                ))),
          );
        },
      ),
    );
  }
}

class InoviceRenderPanel extends StatefulWidget {
  final Invoice invoice;
  final ClientInfo clientInfo;

  const InoviceRenderPanel(
      {super.key, required this.invoice, required this.clientInfo});

  @override
  State<StatefulWidget> createState() => InoviceRenderPanelState();
}

class InoviceRenderPanelState extends State<InoviceRenderPanel> {
  final ExportDelegate exportDelegate = ExportDelegate(
      options:
          const ExportOptions(pageFormatOptions: PageFormatOptions.legal()));
  static const frameID = "invoice";

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
      title: "Invoice",
      subtitle: "",
      trailing: IconButton(
        icon: const Icon(Icons.print),
        onPressed: () async {
          try {
            final pdf = await exportDelegate.exportToPdfDocument(frameID);
            var data = await pdf.save();
            const String mimeType = 'text/plain';
            final XFile textFile =
                XFile.fromData(data, mimeType: mimeType, name: 'invoice.pdf');
            await textFile.saveTo("");
          } catch (e, s) {
            print("$e, $s");
          }
        },
      ),
      initiallyExpanded: true, // this is important to make the page render!!!
      contents: [
        ExportFrame(
            frameId: frameID,
            exportDelegate: exportDelegate,
            child: RenderedInvoiceWidget(
                invoice: widget.invoice, clientInfo: widget.clientInfo))
      ],
    );
  }
}

class ClientInfoPanel extends StatelessWidget {
  final String clientID;

  const ClientInfoPanel({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
      builder: (context, clientRepo, child) => StreamBuilder<Client?>(
        stream: clientRepo.stream(clientID),
        builder: (context, snapshot) {
          var client = snapshot.data;
          if (client == null) {
            return Container();
          }
          return ExpandableInfoPanel(
            title: "Client Info",
            subtitle: client.fullName(),
            contents: [
              ChangeNotifierProvider<ClientID>(
                create: (context) => ClientID(clientID),
                builder: (context, child) => GifFormSection(
                  sectionTitle: generalInfoSection.title,
                  itemRows: generalInfoSection.items,
                  enumType: generalInfoSection.enumType,
                ),
              ),
            ],
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
    setState(() {
      dateBilled = value;
      dateBilledController.text = value?.toIso8601String() ?? "";
    });
    var invoice = value == null
        ? widget.invoice.clearDateBilled()
        : widget.invoice.copyWith(dateBilled: value);
    await widget.invoiceRepo.update(invoice);
  }

  void updateDatePaid(DateTime? value) async {
    setState(() {
      datePaid = value;
      datePaidController.text = value?.toIso8601String() ?? "";
    });
    var invoice = value == null
        ? widget.invoice.clearDatePaid()
        : widget.invoice.copyWith(datePaid: value);
    await widget.invoiceRepo.update(invoice);
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

class MaterialsPanel extends StatelessWidget {
  final Invoice invoice;
  final Invoices invoiceRepo;

  const MaterialsPanel(
      {super.key, required this.invoice, required this.invoiceRepo});

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialsRepo>(
        builder: (context, materialsRepo, child) =>
            StreamBuilder<List<ClientOrder>>(
              stream: materialsRepo.clientOrders(
                  clientID: invoice.clientID, invoiceID: invoice.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                var orders = snapshot.data!;
                double totalPrice = orders.isEmpty
                    ? 0
                    : orders
                        .map((o) => o.totalPrice())
                        .reduce((value, element) => value + element);
                return ExpandableInfoPanel(
                  title: "Materials",
                  subtitle: "$totalPrice ${invoice.currency.name}",
                  contents: orders
                      .map((o) => OverviewTile(
                            attentionLevel: OverviewAttentionLevel.grey,
                            title: "Order for TODO -- ${o.totalPrice()}",
                            icon: Icons.palette,
                            additionalTrailing: [
                              IconButton(
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => NewClientOrderDialog(
                                        repo: materialsRepo,
                                        clientID: invoice.clientID,
                                        editingEnabled: true)),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (await confirmOrderRemoval(context)) {
                                    await invoiceRepo.removeOrder(
                                        invoice, o.id!);
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              )
                            ],
                          ))
                      .toList(),
                );
              },
            ));
  }

  Future<bool> confirmOrderRemoval(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Removal"),
            content: const Text(
                "Would you like to remove this order from the invoice?"),
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

class AppointmentPanel extends StatelessWidget {
  final Invoice invoice;
  final Invoices invoiceRepo;

  const AppointmentPanel(
      {super.key, required this.invoice, required this.invoiceRepo});

  @override
  Widget build(BuildContext context) {
    int totalPrice = invoice.appointmentEntries.isEmpty
        ? 0
        : invoice.appointmentEntries
            .map((e) => e.price)
            .reduce((value, element) => value + element);
    return ExpandableInfoPanel(
      title: "Appointments",
      subtitle: "$totalPrice ${invoice.currency.name}",
      contents: invoice.appointmentEntries
          .map((e) => OverviewTile(
                attentionLevel: OverviewAttentionLevel.grey,
                title:
                    "${e.price} ${invoice.currency.name} for ${e.appointmentType.prettyName()} on ${e.appointmentDate}",
                icon: Icons.event,
                additionalTrailing: [
                  IconButton(
                    onPressed: () => promptForNewPrice(context, e),
                    icon: const Icon(Icons.edit),
                  ),
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

  Future<void> promptForNewPrice(
      BuildContext context, AppointmentEntry entry) async {
    var controller = TextEditingController(text: entry.price.toString());
    var newPrice = await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Appointment Price (${invoice.currency.name})"),
        content: TextFormField(
          controller: controller,
        ),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(int.parse(controller.text)),
              child: const Text("Save")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("Cancel")),
        ],
      ),
    );
    if (newPrice != null) {
      await invoiceRepo.updateAppointmentPrice(
          invoice.clientID, invoice.id!, entry.appointmentID, newPrice);
    }
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
