import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/screens/appointments.dart';
import 'package:provider/provider.dart';

class ClientInfoScreen extends StatelessWidget {
  final Client? client;

  const ClientInfoScreen({Key? key, this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClientInfoForm(client);
  }
}

class ClientInfoForm extends StatefulWidget {
  final Client? _client;

  ClientInfoForm(this._client);

  @override
  State<StatefulWidget> createState() {
    return ClientInfoFormState(_client);
  }
}

class ClientInfoFormState extends State<ClientInfoForm> {
  final Client? _client;

  ClientInfoFormState(this._client);

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _firstNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_client == null ? 'New Client' : 'Client Info'),
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
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_client != null) _buildClientNum(),
              _buildFirstName(),
              _buildLastName(),
              _buildAppointmentSummary(),
              _buildInvoiceSummary(),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final clients = Provider.of<Clients>(context, listen: false);
      var clientNum = _client?.displayNum();
      Future<void> op;
      if (clientNum == null) {
        op = clients.add(
          _firstNameController.value.text,
          _lastNameController.value.text,
        );
      } else {
        op = clients.update(Client(
          _client?.id,
          _client?.num,
          _firstNameController.value.text,
          _lastNameController.value.text,
        ));
      }
      op.then((_) => Navigator.of(context).pop(true));
    }
  }

  Widget _buildInvoiceSummary() {
    return Consumer<Invoices>(builder: (context, invoices, child) {
      if (_client?.id == null) {
        return Container();
      }
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text("Invoice Summary",
                  style: Theme.of(context).textTheme.subtitle2)),
          _buildNumInvoices(invoices.getPending(), "Pending", context),
          _buildNumInvoices(invoices.getReceivable(), "Receivable", context),
          _buildNumInvoices(invoices.getPaid(), "Paid", context),
          Row(
            children: [
              ElevatedButton(
                  child: Text("View All"),
                  onPressed: () {
                    AutoRouter.of(context).push(InvoicesScreenRoute(client: _client));
                  }),
            ],
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      );
    });
  }

  Widget _buildNumInvoices(
      List<Invoice> invoices, String title, BuildContext context) {
    return Row(
      children: [
        _paddedItem(Text(
            "Num Invoices $title: ${invoices.isEmpty ? "None" : invoices.length}")),
        invoices.isEmpty
            ? Container()
            : TextButton(
                child: Text("View"),
                onPressed: () {
                  // TODO: navigate
                }),
      ],
    );
  }

  Widget _buildAppointmentSummary() {
    return Consumer<Appointments>(builder: (context, model, child) {
      if (_client?.id == null) {
        return Container();
      }
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text("Appointment Summary",
                  style: Theme.of(context).textTheme.subtitle2)),
          _buildLastAppointment(model.getLast(_client!.id!), context),
          _buildNextAppointment(model.getNext(_client!.id!), context),
          _buildToBeInvoiced(
              model.getPending(clientId: _client!.id),
              context),
          Row(
            children: [
              ElevatedButton(
                  child: Text("View All"),
                  onPressed: () {
                    AutoRouter.of(context).push(AppointmentsScreenRoute(view: View.ALL, client: _client));
                  }),
            ],
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      );
    });
  }

  Widget _buildLastAppointment(
      Appointment? lastAppointment, BuildContext context) {
    return Row(
      children: [
        _paddedItem(Text(
            "Last Appointment: ${lastAppointment == null ? "None" : lastAppointment.time.toString()}")),
        lastAppointment == null
            ? Container()
            : TextButton(
                child: Text("View"),
                onPressed: () {
                  AutoRouter.of(context).push(AppointmentInfoScreenRoute(appointment: lastAppointment));
                }),
      ],
    );
  }

  Widget _buildNextAppointment(
      Appointment? nextAppointment, BuildContext context) {
    return Row(
      children: [
        _paddedItem(Text(
            "Next Appointment: ${nextAppointment == null ? "None" : nextAppointment.time.toString()}")),
        nextAppointment == null
            ? Container()
            : TextButton(
                child: Text("View"),
                onPressed: () {
                  AutoRouter.of(context).push(AppointmentInfoScreenRoute(appointment: nextAppointment));
                }),
      ],
    );
  }

  Widget _buildToBeInvoiced(
      List<Appointment> appointments, BuildContext context) {
    return Row(
      children: [
        _paddedItem(Text(
            "To Be Invoiced: ${appointments.isEmpty ? "None" : appointments.length}")),
        appointments.isEmpty
            ? Container()
            : TextButton(
                child: Text("View"),
                onPressed: () {
                  AutoRouter.of(context).push(AppointmentsScreenRoute(view: View.PENDING, client: _client));
                }),
      ],
    );
  }

  Widget _paddedItem(Widget child) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0), child: child);
  }

  Widget _buildClientNum() {
    var clientNum = _client?.displayNum().toString();
    return _paddedItem(Row(children: [
      Container(
        child: Text("Client Num:"),
        margin: EdgeInsets.only(right: 10.0),
      ),
      Text(clientNum == null ? "NULL" : clientNum),
    ]));
  }

  Widget _buildFirstName() {
    return _textInput(
        "First Name:", _client?.firstName, _firstNameController, true);
  }

  Widget _buildLastName() {
    return _textInput(
        "Last Name:", _client?.lastName, _lastNameController, false);
  }

  static Widget _textInput(String title, String? value,
      TextEditingController controller, bool autoFocus) {
    if (value != null) {
      controller.text = value;
    }
    return Row(
      children: [
        Container(
          child: Text(title),
          margin: EdgeInsets.only(right: 10.0),
        ),
        Expanded(
          child: TextFormField(
              autofocus: autoFocus && value == null,
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              }),
        ),
      ],
    );
  }
}
