import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/widgets/client_selector.dart';
import 'package:lmlb/widgets/input_container.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:provider/provider.dart';

class InvoiceDetailModel extends ChangeNotifier {
  final Appointments appointmentRepo;
  final Clients clientRepo;

  final String? invoiceId;
  final Invoice? invoice;

  String? clientId;
  Currency? currency;
  List<Appointment> allAppointments = [];
  List<Appointment> invoicedAppointments = [];
  DateTime? dateBilled;
  DateTime? datePaid;

  InvoiceDetailModel({this.invoiceId, this.invoice, this.clientId, this.currency, required this.appointmentRepo, required this.clientRepo}) {
    dateBilled = invoice?.dateBilled;
    datePaid = invoice?.datePaid;
    _updateAppointments();
  }

  Invoice updatedInvoice() {
    return Invoice(
      invoice?.id,
      invoice?.num,
      clientId!,
      currency!,
      invoice?.dateCreated ?? DateTime.now(),
      dateBilled,
      datePaid,
    );
  }

  void updateDatePaid(DateTime? date) {
    datePaid = date;
    notifyListeners();
  }

  void updateDateBilled(DateTime? date) {
    dateBilled = date;
    notifyListeners();
  }

  void updateClientId(String? value) {
    clientId = value;
    _updateCurrency();
    _updateAppointments();
    notifyListeners();
  }

  void _updateCurrency() {
    // Only update currency based on the client info if the invoice has not been
    // saved.
    if (clientId != null && invoiceId == null) {
      clientRepo.get(clientId!).then((client) => currency = client?.currency);
    }
  }

  void _updateAppointments() {
    Future<List<Appointment>> pendingAppointments = appointmentRepo.getPending(clientId: clientId);
    Future<List<Appointment>> invoicedAppointments = invoiceId == null
        ? Future.value([]) : appointmentRepo.getInvoiced(invoiceId!);
    Future.wait([pendingAppointments, invoicedAppointments]).then((appointmentLists) {
      allAppointments.clear();
      allAppointments.addAll(appointmentLists[0]);
      allAppointments.addAll(appointmentLists[1]);
      this.invoicedAppointments.clear();
      this.invoicedAppointments.addAll(appointmentLists[1]);
      notifyListeners();
    });
  }
}

class InvoiceDetailScreen extends StatelessWidget {
  final String? invoiceId;
  final String? clientId;

  const InvoiceDetailScreen({Key? key, @PathParam() this.invoiceId, this.clientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Consumer3<Invoices, Appointments, Clients>(builder: (context, invoiceRepo, appointmentRepo, clientRepo, child) => FutureBuilder<Invoice?>(
      future: invoiceRepo.getSingle(invoiceId),
      builder: (context, snapshot) {
        var invoice = snapshot.data;
        if (invoiceId != null && invoice == null) {
          return Container();
        }
        var createModel = (context) {
          var model = InvoiceDetailModel(
            invoice: invoice,
            invoiceId: invoiceId,
            clientId: clientId ?? invoice?.clientId,
            currency: invoice?.currency,
            appointmentRepo: appointmentRepo,
            clientRepo: clientRepo,
          );
          model.updateClientId(clientId ?? invoice?.clientId);
          return model;
        };

        return ChangeNotifierProvider(create: createModel, child: content(context, invoice));
      },
    ));
  }

  Widget content(BuildContext context, Invoice? invoice) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(invoice == null
            ? 'New Invoice'
            : 'Invoice #${invoice.invoiceNumStr()}'),
        actions: [
          Consumer2<Invoices, InvoiceDetailModel>(builder: (context, invoiceRepo, model, child) => TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () {
              invoiceRepo.update(model.updatedInvoice()).then((_) => AutoRouter.of(context).pop());
            },
          )),
        ],
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClientSelector(context, invoice),
              _buildCurrencySelector(context),
              _buildDateBilled(),
              _buildDatePaid(),
              _buildAppointmentSelector(context),
              //_buildTotal(context),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCurrencySelector(BuildContext context) {
    var widget = Consumer<InvoiceDetailModel>(builder: (context, model, child) => Text(
      model.currency?.name ?? "IDK"));
    return InputContainer(title: "Currency:", content: widget);
  }

  Widget _buildAppointmentSelector(BuildContext context) {
    List<Map<String, Object>> formatDataSource(List<Appointment> appointments) {
      return appointments
          .map((a) => {
        'display':
        "${a.type.name()} on ${DateFormat("d MMM").format(a.time)}",
        'value': a
      }).toList();
    }
    var formField = FormField(
      builder: (state) => Consumer<InvoiceDetailModel>(builder: (context, model, child) {
        var noClientWidget = Text(
          "Please select a client",
          style: TextStyle(fontStyle: FontStyle.italic),
        );

        var selectorWidget = Expanded(child: MultiSelectFormField(chipBackGroundColor: ThemeData.light().dialogBackgroundColor,
          chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
          checkBoxActiveColor: ThemeData.light().colorScheme.secondary,
          checkBoxCheckColor: Colors.black,
          dialogShapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          title: Text("Appointments to bill", style: TextStyle(fontWeight: FontWeight.bold)),
          dataSource: formatDataSource(model.allAppointments),
          textField: 'display',
          valueField: 'value',
          okButtonLabel: 'OK',
          cancelButtonLabel: 'CANCEL',
          hintWidget: Text('Please choose one or more'),
          initialValue: model.invoicedAppointments,
          onSaved: (value) {
            state.didChange(value);
            /*setState(() {
              _appointments = List<Appointment>.from(value);
            });*/
          },
        ));
        return model.clientId == null ? noClientWidget : selectorWidget;
      }),
    );
    return InputContainer(title: null, content: formField);
  }


  Widget _buildClientSelector(BuildContext context, Invoice? invoice) {
    return Consumer<InvoiceDetailModel>(builder: (context, model, child) => ClientSelector(
      canEdit: invoice == null,
      includeInactive: false,
      selectedClientId: invoice?.clientId,
      onUpdate: model.updateClientId,
    ));
  }

  Widget _showErrorOrDisplay(FormFieldState state, Widget display) {
    return Column(
      children: [
        display,
        state.hasError
            ? Text(
          state.errorText!,
          style: TextStyle(color: Colors.red),
        )
            : Container()
      ],
    );
  }

  Widget _buildDateWidget(BuildContext context, String title, Function(DateTime?) onUpdate, DateTime? value) {
    final Widget display = value == null
        ? Text("Select a date") : Text(value.toIso8601String());
    final Widget widget = FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null) {
          return "Date required";
        }
        return null;
      },
      builder: (state) => GestureDetector(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(), // Refer step 1
            firstDate: DateTime.now().subtract(Duration(days: 365)),
            lastDate: DateTime.now().add(Duration(days: 365)),
          );
          if (picked != null) {
            state.didChange(picked);
            onUpdate(picked);
          }
        },
        child: _showErrorOrDisplay(state, display),
      ),
    );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      InputContainer(title: title, content: widget),
      if (value != null) TextButton(onPressed: () => onUpdate(null), child: Text("Clear")),
    ]);
  }

  Widget _buildDateBilled() {
    return Consumer<InvoiceDetailModel>(builder: (context, model, child) {
      return _buildDateWidget(context, "Date Billed:", model.updateDateBilled, model.dateBilled);
    });
  }

  Widget _buildDatePaid() {
    return Consumer<InvoiceDetailModel>(builder: (context, model, child) {
      return _buildDateWidget(context, "Date Paid:", model.updateDatePaid, model.datePaid);
    });
  }
}

