
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:provider/provider.dart';

class NotesPanel extends StatelessWidget {
  final String? clientID;

  const NotesPanel({super.key, this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(builder: (context, clientRepo, child) => FutureBuilder<Client?>(
        future: clientRepo.get(clientID!),
        builder: (context, snapshot) {
          if (snapshot.data?.num == null) {
            return Container();
          }
          return ExpandableInfoPanel(
            title: "Notes",
            subtitle: "",
            initiallyExpanded: false,
            contents: [
              OverviewTile(
                attentionLevel: OverviewAttentionLevel.GREY,
                title: "FUP 2 Notes",
                subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                icon: Icons.note,
                actions: [
                  OverviewAction(title: "Edit"),
                ],
              ),
              OverviewTile(
                attentionLevel: OverviewAttentionLevel.GREY,
                title: "FUP 1 Notes",
                subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                icon: Icons.note,
                actions: [
                  OverviewAction(title: "Edit"),
                ],
              ),
            ],
          );
        }));
  }
}
