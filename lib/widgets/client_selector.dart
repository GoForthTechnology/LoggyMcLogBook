import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/input_container.dart';
import 'package:provider/provider.dart';

class ClientSelectorModel extends ChangeNotifier {
  String? clientId;

  ClientSelectorModel(this.clientId);

  void updateClientId(String? value) {
    clientId = value;
    notifyListeners();
  }
}

class ClientSelector extends StatelessWidget {
  final bool canEdit;
  final String? selectedClientId;
  final Function(String?) onUpdate;

  ClientSelector({Key? key, required this.canEdit, required this.selectedClientId, required this.onUpdate}) : super(key: key) {
    if (!canEdit && selectedClientId == null) {
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClientSelectorModel(selectedClientId),
      child: canEdit ? _buildSelectorWidget(context) : _buildClientNameWidget(),
    );
  }

  Widget _buildClientNameWidget() {
    return Consumer<Clients>(builder: (context, clientsRepo, child) => FutureBuilder<Client?>(
      future: clientsRepo.get(selectedClientId!),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return InputContainer(
            title: "Client:",
            content: Text("TBD"),
          );
        }
        var client = snapshot.data!;
        return InputContainer(
          title: "Client:",
          content: Text("${client.firstName} ${client.lastName} #${client.displayNum()}"),
        );
      },
    ));
  }

  Widget _buildSelectorWidget(BuildContext context) {
    var validator = (value) {
      if (value == null) {
        return "Select a value";
      }
      return null;
    };
    var contentBuilder = (state) => Consumer2<Clients, ClientSelectorModel>(builder: (context, clientModel, screenModel, child) {
      return FutureBuilder<List<Client>>(
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
              onUpdate(selection);
            },
            value: screenModel.clientId,
          );
          return button;
        },
      );
    });
    var formField = FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      builder: contentBuilder,
    );
    return InputContainer(title: "Client:", content: formField);
  }
}