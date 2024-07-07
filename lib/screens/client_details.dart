import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/action_items_panel.dart';
import 'package:lmlb/widgets/appointments_panel.dart';
import 'package:lmlb/widgets/billing_panel.dart';
import 'package:lmlb/widgets/gif_form.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/notes_panel.dart';
import 'package:lmlb/widgets/reproductive_history_panel.dart';
import 'package:provider/provider.dart';

class ClientDetailsScreen extends StatelessWidget {
  final String clientId;
  final formKey = GlobalKey<FormState>();

  ClientDetailsScreen({Key? key, @PathParam() required this.clientId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
      builder: (context, clientRepo, child) => FutureBuilder<Client?>(
          future: clientRepo.get(clientId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            var client = snapshot.data!;
            bool hasClientNum = client.num != null;
            bool isActive = client.active ?? false;
            List<Widget> actions = [];
            if (hasClientNum && isActive) {
              actions.add(Tooltip(
                  message: "Deactivate Client",
                  child: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () =>
                        clientRepo.deactivate(snapshot.data!).ignore(),
                  )));
            } else if (hasClientNum && !isActive) {
              actions.add(Tooltip(
                  message: "Activate Client",
                  child: IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: () =>
                        clientRepo.activate(snapshot.data!).ignore(),
                  )));
            }
            return NavigationRailScreen(
              item: NavigationItem.CLIENTS,
              title: Text(
                  'Details for ${snapshot.data!.firstName} ${snapshot.data!.lastName}'),
              content: ListView(children: [
                ActionItemsPanel(
                  clientID: clientId,
                ),
                AppointmentsPanel(
                  clientID: clientId,
                ),
                BillingPanel(
                  clientID: clientId,
                ),
                NotesPanel(
                  clientID: clientId,
                ),
                ReproductiveHistoryPanel(
                  client: client,
                ),
                GifForm(
                  clientID: clientId,
                ),
              ]),
            );
          }),
    );
  }
}
