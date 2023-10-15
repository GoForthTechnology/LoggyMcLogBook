

import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/widgets/filter_bar.dart';
import 'package:provider/provider.dart';

import 'client_list_model.dart';

final _clientFilters = [
  Filter<ClientData>(label: "Active Clients", predicate: (cd) => cd.client.status() == ClientStatus.Active),
  Filter<ClientData>(label: "Inactive Clients", predicate: (cd) => cd.client.status() == ClientStatus.Inactive),
  Filter<ClientData>(label: "Prospective Clients", predicate: (cd) => cd.client.status() == ClientStatus.Prospective),
];

final _defaultClientSort = Sort<ClientData>(
  label: "By ID",
  comparator: (a, b) => a.client.id!.compareTo(b.client.id!),
);

final _additionalClientSorts = [
  Sort<ClientData>(
    label: "By Name",
    comparator: (a, b) => a.client.fullName().compareTo(b.client.fullName()),
  ),
  Sort<ClientData>(
    label: "By Number",
    comparator: (a, b) {
      var aNum = a.client.num;
      var bNum = b.client.num;
      if (aNum == null && bNum == null) {
        return 0;
      }
      if (aNum == null && bNum != null) {
        return 1;
      }
      if (aNum != null && bNum == null) {
        return -1;
      }
      return aNum!.compareTo(bNum!);
    },
  ),
];

class ClientListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClientListData>(
      stream: Provider.of<ClientListModel>(context).data,
      initialData: new ClientListData([]),
      builder: (context, snapshot) {
        var clients = snapshot.data?.clientData ?? [];
        return ChangeNotifierProvider<FilterBarModel<ClientData>>(
          create: (context) => FilterBarModel<ClientData>(
            filters: _clientFilters,
            defaultSort: _defaultClientSort,
            additionalSortingOptions: _additionalClientSorts,
          ),
          builder: (context, child) => Column(children: [
            FilterBar<ClientData>(),
            Consumer<FilterBarModel<ClientData>>(builder: (context, model, child) {
              var filteredClients = clients.where((cd) => model.filter(cd)).toList();
              var sortedClients = model.getSorted(filteredClients);
              return Expanded(child: ListView.builder(
                itemCount: sortedClients.length,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemBuilder: (context, index) => ClientTile(sortedClients[index]),
              ));
            }),
          ]),
        );
      },
    );
  }
}

class ClientTile extends StatelessWidget {
  final ClientData client;

  ClientTile(this.client);

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        key: Key('client_text_${client.id}'),
        title: Text(client.tile),
        leading: ClientIconWidget(data: client.icon),
        onTap: () => Provider.of<ClientListModel>(context, listen: false).onClientTapped(context, client.id),
      ),
    ));
  }
}

class ClientIconWidget extends StatelessWidget {
  final ClientIcon data;

  const ClientIconWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: data.tooltip,
      child: CircleAvatar(
        backgroundColor: data.color,
      ),
    );
  }

}
