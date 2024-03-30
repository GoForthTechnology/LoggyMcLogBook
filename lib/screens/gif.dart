
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/widgets/gif_form.dart';


class GifScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("General Intake Form"),),
      body: SingleChildScrollView(child: GifBody(clientID: "FOO",)),
    );
  }
}