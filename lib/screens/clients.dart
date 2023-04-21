
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/widgets/client_list/client_list_model.dart';
import 'package:lmlb/widgets/client_list/client_list_widget.dart';
import 'package:provider/provider.dart';

class ClientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(builder: (context, clients, child) => ChangeNotifierProvider(
      create: (context) => ClientListModel(
          onClientTapped: goToClientDetail,
          clients: clients,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clients'),
        ),
        body: ClientListWidget(),
        floatingActionButton: FloatingActionButton(
          // isExtended: true,
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
          onPressed: () => addClient(context),
        ),
      ),
    ));
  }

  void goToClientDetail(BuildContext context, String? clientId) {
    AutoRouter.of(context).push(ClientDetailsScreenRoute(clientId: clientId))
        .then((result) {
      if (result != null && result as bool) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Client updated')));
      }
    });
  }

  void addClient(BuildContext context) {
    AutoRouter.of(context).push(NewClientScreenRoute())
        .then((updated) {
      if (updated as bool) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Client added')));
      }
    });
  }
}
