import 'package:flutter/material.dart';

class WarningWidget extends StatelessWidget {
  final List<String> warnings;

  const WarningWidget({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) {
      return Container();
    }
    return Tooltip(message: warnings.join("\n"), child: Icon(Icons.warning));
  }
}
