import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/screens/appointments.dart';
import 'package:provider/provider.dart';

class ClientDetailsScreen extends StatefulWidget {
  final String? clientId;

  const ClientDetailsScreen({Key? key, @PathParam() this.clientId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ClientDetailsState();
}

class ClientDetailModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final Client? client;

  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  Currency? currencyValue;

  ClientDetailModel(this.client) {
    firstNameController.text = client?.firstName ?? "";
    lastNameController.text = client?.lastName ?? "";
    currencyValue = client?.currency;
  }

  void updateCurrency(Currency? value) {
    currencyValue = value;
    notifyListeners();
  }
}

class ClientDetailsState extends State<ClientDetailsScreen> {

  ClientDetailsState();

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(builder: (context, clientModel, child) => FutureBuilder<Client?>(
      future: widget.clientId == null ? Future.value(null) : clientModel.get(widget.clientId!),
      builder: (context, snapshot) {
        var client = snapshot.data;
        if (widget.clientId != null && client == null) {
          return Container();
        }
        return ChangeNotifierProvider(create: (context) => ClientDetailModel(client), child: Scaffold(
          appBar: AppBar(
            title: Text(client == null ? 'New Client' : 'Client Details'),
            actions: [
              Consumer<ClientDetailModel>(builder: (context, model, child) => TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: () => _onSave(model),
              ))
            ],
          ),
          body: Consumer<ClientDetailModel>(builder: (context, model, child) => Form(
            key: model.formKey,
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (client != null) _buildClientNum(client),
                  _buildFirstName(model),
                  _buildLastName(model),
                  _buildCurrencySelector(model),
                  Row(children: [
                    Spacer(),
                    _buildAppointmentSummary(client),
                    Spacer(),
                    _buildInvoiceSummary(client),
                    Spacer(),
                  ]),
                  if (client != null) _buildActivateDeactivate(client, clientModel),
                ],
              ),
            ),
          )),
        ));
      }));
  }

  Widget _buildCurrencySelector(ClientDetailModel model) {
    var dropDownButton = DropdownButton<Currency>(
      hint: Text('Please make a selection'),
      items: Currency.values.map((enumValue) {
        return DropdownMenuItem<Currency>(
          value: enumValue,
          child: new Text(enumValue.toString().split(".")[1]),
        );
      }).toList(),
      onChanged: (selection) {
        model.updateCurrency(selection);
      },
      value: model.currencyValue,
    );
    var formField = FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //validator: validator,
      builder: (state) => dropDownButton,
    );
    return _inputWidget("Currency:", formField);
  }

  void _onSave(ClientDetailModel model) {
    if (!model.formKey.currentState!.validate()) {
      return;
    }
    final clients = Provider.of<Clients>(context, listen: false);
    Future<void> op;
    if (model.client?.num == null) {
      op = clients.add(
        model.firstNameController.text,
        model.lastNameController.text,
        model.currencyValue!,
      );
    } else {
      op = clients.update(Client(
        model.client?.id,
        model.client?.num,
        model.firstNameController.text,
        model.lastNameController.text,
        model.currencyValue,
        model.client?.active,
      ));
    }
    op.then((_) => Navigator.of(context).pop(true));
  }

  Widget _buildInvoiceSummary(Client? client) {
    return Consumer<Invoices>(builder: (context, invoices, child) {
      if (client?.id == null) {
        return Container();
      }
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text("Invoice Summary",
                  style: Theme.of(context).textTheme.titleMedium)),
          _buildNumInvoices(invoices.getPending(), "Pending", context),
          _buildNumInvoices(invoices.getReceivable(), "Receivable", context),
          _buildNumInvoices(invoices.getPaid(), "Paid", context),
          Row(
            children: [
              ElevatedButton(
                  child: Text("View All"),
                  onPressed: () {
                    AutoRouter.of(context).push(InvoicesScreenRoute(client: client));
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

  Widget _buildAppointmentSummary(Client? client) {
    return Consumer<Appointments>(builder: (context, model, child) {
      var clientId = client?.id;
      if (clientId == null) {
        return Container();
      }
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text("Appointment Summary",
                  style: Theme.of(context).textTheme.titleMedium))),
          _buildLastAppointment(model, clientId, context),
          _buildNextAppointment(model, clientId, context),
          _buildToBeInvoiced(
              model.getPending(clientId: clientId),
              context, client),
          Row(
            children: [
              ElevatedButton(
                  child: Text("View All"),
                  onPressed: () {
                    AutoRouter.of(context).push(AppointmentsScreenRoute(view: View.ALL.name, client: client));
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
      Appointments appointmentsRepo, String clientId, BuildContext context) {
    return FutureBuilder<Appointment?>(
      future: appointmentsRepo.getLast(clientId),
      builder: (context, snapshot) {
        var lastAppointment = snapshot.data;
        return Row(
          children: [
            _paddedItem(Text(
                "Last Appointment: ${lastAppointment == null ? "None" : lastAppointment.time.toString()}")),
            lastAppointment == null
                ? Container()
                : TextButton(
                child: Text("View"),
                onPressed: () {
                  AutoRouter.of(context).push(AppointmentInfoScreenRoute(appointmentId: lastAppointment.id));
                }),
          ],
        );
      },
    );
  }

  Widget _buildNextAppointment(
      Appointments appointmentRepo, String clientId, BuildContext context) {
    return FutureBuilder<Appointment?>(
      future: appointmentRepo.getNext(clientId),
      builder: (context, snapshot) {
        var nextAppointment = snapshot.data;
        return Row(
          children: [
            _paddedItem(Text(
                "Next Appointment: ${nextAppointment == null ? "None" : nextAppointment.time.toString()}")),
            nextAppointment == null? Container() : TextButton(
              child: Text("View"),
              onPressed: () {
                AutoRouter.of(context).push(AppointmentInfoScreenRoute(appointmentId: nextAppointment.id));
              },
            ),
          ]);
      },
    );
  }

  Widget _buildToBeInvoiced(
      Future<List<Appointment>> appointmentsF, BuildContext context, Client? client) {
    return FutureBuilder<List<Appointment>>(
      future: appointmentsF,
      builder: (context, snapshot) {
        var appointments = snapshot.data ?? [];
        return Row(
          children: [
            _paddedItem(Text(
                "To Be Invoiced: ${appointments.isEmpty ? "None" : appointments.length}")),
            appointments.isEmpty
                ? Container()
                : TextButton(
                child: Text("View"),
                onPressed: () {
                  AutoRouter.of(context).push(AppointmentsScreenRoute(view: View.PENDING.name, client: client));
                }),
          ],
        );
      },
    );
  }

  Widget _paddedItem(Widget child) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0), child: child);
  }

  Widget _buildClientNum(Client client) {
    return _paddedItem(Consumer<Clients>(builder: (context, clientsRepo, child) {
      var clientNum = client.num;
      var widget = clientNum == null
          ? ElevatedButton(onPressed: () => clientsRepo.assignClientNum(client), child: Text("Assign Number"),)
          : Text(client.displayNum()!);
      return Row(children: [
        Container(
          child: Text("Client Num:"),
          margin: EdgeInsets.only(right: 10.0),
        ),
        widget,
      ]);
    }));
  }

  Widget _buildFirstName(ClientDetailModel model) {
    return _textInput(
        "First Name:", model.client?.firstName, model.firstNameController, true);
  }

  Widget _buildLastName(ClientDetailModel model) {
    return _textInput(
        "Last Name:", model.client?.lastName, model.lastNameController, false);
  }

  Widget _buildActivateDeactivate(Client client, Clients clientModel) {
    Widget text;
    Function() onPressed;
    var isActive = client.active ?? false;
    if (isActive) {
      text = Text("Deactivate");
      onPressed = () => clientModel.deactivate(client);
    } else {
      text = Text("Reactivate");
      onPressed = () => clientModel.activate(client);
    }
    return Padding(padding: EdgeInsets.all(20), child: Center(child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.red : Colors.green,
      ),
      child: text,
    )));
  }

  static Widget _inputWidget(String title, Widget child) {
    return Row(
      children: [
        Container(
          child: Text(title),
          margin: EdgeInsets.only(right: 10.0),
        ),
        Expanded(child: child),
      ],
    );
  }

  static Widget _textInput(String title, String? value,
      TextEditingController controller, bool autoFocus) {
    if (value != null) {
      controller.text = value;
    }
    Widget child = TextFormField(
      autofocus: autoFocus && value == null,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
    return _inputWidget(title, child);
  }
}
