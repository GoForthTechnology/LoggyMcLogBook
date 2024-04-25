import 'package:flutter/material.dart';
import 'package:lmlb/widgets/info_panel.dart';

class CrudTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> contents;
  final bool Function() showSave;
  final Function() onSave;
  final Function() onRemove;

  const CrudTile(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.contents,
      required this.showSave,
      required this.onSave,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
      title: title,
      subtitle: subtitle,
      contents: [
        ...contents,
        Center(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Spacer(),
            if (showSave())
              IconButton(
                icon: Icon(Icons.save),
                onPressed: onSave,
              ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmRemoval(context),
            ),
            Spacer(),
          ],
        ))
      ],
    );
  }

  void _confirmRemoval(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Confirm Delete"),
              content: Text("Are you sure you want to delete this item?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      onRemove();
                      Navigator.of(context).pop();
                    },
                    child: Text("Confirm")),
              ],
            ));
  }
}
