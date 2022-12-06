import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:provider/provider.dart';

class InvoiceInfoScreen extends StatelessWidget {
  final Invoice? invoice;

  const InvoiceInfoScreen({Key? key, this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InvoiceInfoForm(invoice);
  }
}

class InvoiceInfoForm extends StatefulWidget {
  final Invoice? _invoice;

  InvoiceInfoForm(this._invoice);

  @override
  State<StatefulWidget> createState() {
    return InvoiceInfoFormState(_invoice);
  }
}

class InvoiceInfoFormState extends State<InvoiceInfoForm> {
  final _formKey = GlobalKey<FormState>();

  late final Invoice? _invoice;
  late List<Appointment> _appointments;
  Currency? _currency;
  String? _clientId;

  InvoiceInfoFormState(Invoice? invoice) {
    this._invoice = invoice;
    this._clientId = _invoice?.clientId;
    this._currency = _invoice?.currency;
  }

  @override
  void initState() {
    super.initState();
    final appointmentsRepo = Provider.of<Appointments>(context, listen: false);
    this._appointments =
        _invoice == null ? [] : appointmentsRepo.getInvoiced(_invoice!.id!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<Clients>(context, listen: false).getAll().isEmpty) {
        Widget continueButton = TextButton(
          child: Text("Ack"),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("No Clients Found"),
          content: Text("Please add the client before creating an invoice"),
          actions: [
            continueButton,
          ],
        );
        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_invoice == null
            ? 'New Invoice'
            : 'Invoice #${_invoice!.invoiceNumStr()}'),
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

  Widget _buildAppointmentSelector(BuildContext context) {
    return _buildContainer(
        null,
        FormField(
          builder: (state) =>
              Consumer<Appointments>(builder: (context, repo, child) {
            return _clientId == null
                ? Text("Please select a client",
                    style: TextStyle(fontStyle: FontStyle.italic))
                : Expanded(
                    child: MultiSelectFormField(
                        chipBackGroundColor: ThemeData.light().dialogBackgroundColor,
                        chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                        dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        checkBoxActiveColor: ThemeData.light().colorScheme.secondary,
                        checkBoxCheckColor: Colors.black,
                        dialogShapeBorder: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0))),
                        title: Text("Appointments to bill",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        dataSource: _formatDataSource(_invoice == null
                            ? repo.getPending(clientId: _clientId)
                            : repo.get(
                                clientId: _clientId,
                                predicate: (a) =>
                                    a.invoiceId == _invoice!.id ||
                                    a.invoiceId == null)),
                        textField: 'display',
                        valueField: 'value',
                        okButtonLabel: 'OK',
                        cancelButtonLabel: 'CANCEL',
                        hintWidget: Text('Please choose one or more'),
                        initialValue: _appointments,
                        onSaved: (value) {
                          state.didChange(value);
                          setState(() {
                            _appointments = List<Appointment>.from(value);
                          });
                        }));
          }),
        ));
  }

  List<Map<String, Object>> _formatDataSource(List<Appointment> appointments) {
    return appointments
        .map((a) => {
              'display':
                  "${a.type.name()} on ${DateFormat("d MMM").format(a.time)}",
              'value': a
            })
        .toList();
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return _buildContainer(
        "Currency:",
        FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null) {
                return "Select a value";
              }
              return null;
            },
            builder: (state) => _showErrorOrDisplay(
                state,
                DropdownButton<Currency>(
                  hint: Text('Please make a selection'),
                  items: Currency.values.map((enumValue) {
                    return DropdownMenuItem<Currency>(
                      value: enumValue,
                      child: new Text(enumValue.toString().split(".")[1]),
                    );
                  }).toList(),
                  onChanged: (selection) {
                    state.didChange(selection);
                    setState(() {
                      _currency = selection;
                    });
                  },
                  value: _currency,
                ))));
  }

  Widget _buildClientSelector(BuildContext context) {
    return _buildContainer(
        "Client:",
        FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null) {
                return "Select a value";
              }
              return null;
            },
            builder: (state) => Consumer<Clients>(
                builder: (context, clientModel, child) => _showErrorOrDisplay(
                    state,
                    DropdownButton<Client>(
                      hint: Text('Please make a selection'),
                      items: clientModel.getAll().map((client) {
                        return DropdownMenuItem<Client>(
                          value: client,
                          child: new Text(client.fullName()),
                        );
                      }).toList(),
                      onChanged: (selection) {
                        state.didChange(selection);
                        setState(() {
                          _clientId = selection!.id;
                        });
                      },
                      value: _clientId == null
                          ? null
                          : clientModel.get(_clientId!),
                    )))));
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
