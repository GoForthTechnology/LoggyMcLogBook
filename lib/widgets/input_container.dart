import 'package:flutter/cupertino.dart';

class InputContainer extends StatelessWidget {
  final String? title;
  final Widget content;

  const InputContainer({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(children: [
        title == null
            ? Container()
            : Container(
                margin: const EdgeInsets.only(right: 10.0),
                child: Text(title!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
        content,
      ]),
    );
  }
}
