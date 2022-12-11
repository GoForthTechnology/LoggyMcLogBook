import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:provider/provider.dart';

class InvoiceInfoModel extends ChangeNotifier {
  final Appointments appointmentRepo;
  final Clients clientRepo;

  final String? invoiceId;
  String? clientId;
  Currency? currency;
  List<Appointment> allAppointments = [];
  List<Appointment> invoicedAppointments = [];

  InvoiceInfoModel({this.invoiceId, this.clientId, this.currency, required this.appointmentRepo, required this.clientRepo}) {
    _updateAppointments();
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

class InvoiceInfoScreen extends StatelessWidget {
  final String? invoiceId;
  final String? clientId;

  const InvoiceInfoScreen({Key? key, @PathParam() this.invoiceId, this.clientId}) : super(key: key);

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
          var model = InvoiceInfoModel(
            invoiceId: invoiceId,
            clientId: clientId ?? invoice?.clientId,
            currency: invoice?.currency,
            appointmentRepo: appointmentRepo,
            clientRepo: clientRepo);
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
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () {},
          )
        ],
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClientSelector(context),
              _buildCurrencySelector(context),
              _buildAppointmentSelector(context),
              //_buildTotal(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    var widget = Consumer<InvoiceInfoModel>(builder: (context, model, child) => Text(
      model.currency?.name ?? "IDK"));
    return _buildContainer("Currency:", widget);
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
      builder: (state) => Consumer<InvoiceInfoModel>(builder: (context, model, child) {
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
    return _buildContainer(null, formField);
  }

  Widget _buildClientSelector(BuildContext context) {
    var validator = (value) {
      if (value == null) {
        return "Select a value";
      }
      return null;
    };
    var contentBuilder = (state) => Consumer2<Clients, InvoiceInfoModel>(builder: (context, clientModel, screenModel, child) {
      var widget = FutureBuilder<List<Client>>(
        future: clientModel.getAll(),
        builder: (context, snapshot) {
          var clients = snapshot.data ?? [];
          var button = DropdownButton<String?>(
            hint: Text('Please make a selection'),
            items: clients.map((client) {
              return DropdownMenuItem<String?>(
                value: client.id,
                child: new Text(client.fullName()),
              );
            }).toList(),
            onChanged: (selection) {
              state.didChange(selection);
              screenModel.updateClientId(selection);
            },
            value: screenModel.clientId,
          );
          return button;
        },
      );
      return _showErrorOrDisplay(state, widget);
    });
    var formField = FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      builder: contentBuilder,
    );
    return _buildContainer("Client:", formField);
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

  Widget _buildContainer(String? title, Widget content) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(children: [
        title == null
            ? Container()
            : Container(
          child:
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          margin: EdgeInsets.only(right: 10.0),
        ),
        content,
      ]),
    );
  }
}

/*class InvoiceInfoScreen extends StatefulWidget {
  final String? invoiceId;
  final String? clientId;

  const InvoiceInfoScreen({Key? key, @PathParam() this.invoiceId, this.clientId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InvoiceInfoFormState();
}

class InvoiceInfoFormState extends State<InvoiceInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Appointment> _appointments = [];
  Currency? _currency;
  String? _clientId;

  @override
  void initState() {
    _clientId = widget.clientId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.invoiceId != null) {
        var invoice = await Provider.of<Invoices>(context, listen: false).getSingle(widget.invoiceId);
        var eligibleInvoices = await Provider.of<Appointments>(context, listen: false).getPending(clientId: _clientId);
        var selectedAppointments = await Provider.of<Appointments>(context, listen: false).getInvoiced(widget.invoiceId!);
        setState(() {
          _appointments.addAll(selectedAppointments);
          if (invoice != null) {
            _currency = invoice.currency;
            _clientId = invoice.clientId;
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Invoices>(builder: (context, model, child) => FutureBuilder<Invoice?>(
      future: widget.invoiceId == null ? Future.value(null) : model.getSingle(widget.invoiceId!),
      builder: (context, snapshot) {
        var invoice = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(invoice == null
                ? 'New Invoice'
                : 'Invoice #${invoice.invoiceNumStr()}'),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: _onSave,
              )
            ],
          ),
          body: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClientSelector(context),
                  _buildCurrencySelector(context),
                  _buildAppointmentSelector(context),
                  _buildTotal(context),
                ],
              ),
            ),
          ),
        );
      }));
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      Provider.of<Invoices>(context, listen: false)
          .add(_clientId!, _currency!, _appointments)
          .then((_) => Navigator.of(context).pop(true));
    } else {
      print("Validation error");
    }
  }

  Widget _buildTotal(BuildContext context) {
    return _buildContainer(
        "Invoice Total:",
        Text(_clientId == null
            ? "Select a client"
            : _currency == null
                ? "Select a currency"
                : "${_appointments.isEmpty ? 0 : _appointments.map((a) => a.type.price(_currency!)).reduce((a, b) => a + b)} ${_currency.toString().split(".")[1]}"));
  }

}*/
