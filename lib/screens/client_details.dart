import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/appointments_summary.dart';
import 'package:lmlb/widgets/client_info.dart';
import 'package:lmlb/widgets/invoices_summary.dart';
import 'package:provider/provider.dart';

class ClientDetailsScreen extends StatelessWidget {
  final String? clientId;
  final formKey = GlobalKey<FormState>();

  ClientDetailsScreen({Key? key, @PathParam() this.clientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
        builder: (context, clientModel, child) => ChangeNotifierProvider(
              create: (context) => ClientInfoModel(clientModel, clientId),
              child: Scaffold(
                appBar: AppBar(
                  title:
                      Text(clientId == null ? 'New Client' : 'Client Details'),
                  actions: [
                    Consumer<ClientInfoModel>(
                        builder: (context, model, child) =>
                            StreamProvider.value(
                              value: model.state(),
                              initialData: model.initialState(),
                              builder: (context, child) =>
                                  Consumer<ClientInfoState>(
                                builder: (context, state, child) =>
                                    TextButton.icon(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.white),
                                  icon: const Icon(Icons.save),
                                  label: const Text('Save'),
                                  onPressed: () {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    model.save(state).then(
                                        (_) => Navigator.of(context).pop(true));
                                  },
                                ),
                              ),
                            )),
                  ],
                ),
                body: Consumer<ClientInfoModel>(
                    builder: (context, model, child) => Form(
                          key: formKey,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClientInfoWidget(),
                                if (model.client?.isActive() ?? false)
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Spacer(),
                                        AppointmentsSummaryWidget.create(
                                            model.client!),
                                        Spacer(),
                                        InvoicesSummaryWidget.create(
                                            model.client!),
                                        Spacer(),
                                      ]),
                                if (model.client != null) _buildActivateDeactivate(model.client!, clientModel),
                              ],
                            ),
                          ),
                        )),
              ),
            ));
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
    return Padding(
        padding: EdgeInsets.all(20),
        child: Center(
            child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.red : Colors.green,
          ),
          child: text,
        )));
  }
}
