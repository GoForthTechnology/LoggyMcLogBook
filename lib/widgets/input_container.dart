import 'package:flutter/cupertino.dart';

class InputContainer extends StatelessWidget {
  final String? title;
  final Widget content;

  const InputContainer({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(children: [
        title == null ? Container() : Container(
          child:
          Text(title!, style: TextStyle(fontWeight: FontWeight.bold)),
          margin: EdgeInsets.only(right: 10.0),
        ),
        content,
      ]),
    );
  }
}