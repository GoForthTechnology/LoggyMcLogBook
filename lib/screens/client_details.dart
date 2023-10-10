import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/client_detail/client_detail.dart';
import 'package:provider/provider.dart';

class ClientDetailsScreen extends StatelessWidget {
  final String clientId;
  final formKey = GlobalKey<FormState>();

  ClientDetailsScreen({Key? key, @PathParam() required this.clientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Loading details for client $clientId");
    return Consumer<Clients>(builder: (context, clientRepo, child) => FutureBuilder<Client?>(
      future: clientRepo.get(clientId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        bool hasClientNum = snapshot.data?.num != null;
        bool isActive = snapshot.data?.active ?? false;
        List<Widget> actions = [];
        if (hasClientNum && isActive) {
          actions.add(Tooltip(message: "Deactivate Client", child: IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () => clientRepo.deactivate(snapshot.data!).ignore(),
          )));
        } else if (hasClientNum && !isActive) {
          actions.add(Tooltip(message: "Activate Client", child: IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () => clientRepo.activate(snapshot.data!).ignore(),
          )));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Details for ${snapshot.data!.firstName} ${snapshot.data!.lastName}'),
            actions: actions,
          ),
          body: ClientDetailsWidget(clientID: clientId,),
        );
      },
    ));
  }
}
