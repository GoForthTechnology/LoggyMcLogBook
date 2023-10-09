import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/widgets/client_detail/client_detail.dart';

class ClientDetailsScreen extends StatelessWidget {
  final String? clientId;
  final formKey = GlobalKey<FormState>();

  ClientDetailsScreen({Key? key, @PathParam() this.clientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clientId == null ? 'New Client' : 'Client Details'),
      ),
      body: ClientDetailsWidget(clientID: clientId!,),
    );
  }
}
