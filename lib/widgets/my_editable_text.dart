import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class MyEditableText extends StatefulWidget {
  final Future<String> initialText;
  final Future<void> Function(String) onSave;
  final Function(Exception) onError;

  const MyEditableText({super.key, required this.initialText, required this.onSave, required this.onError});

  @override
  State<StatefulWidget> createState() => _EditableTextState();
}

class _EditableTextState extends State<MyEditableText> {
  String tmpText = "";
  bool hovering = false;
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      initialData: "",
      future: widget.initialText,
      builder: (context, snapshot) => editing
          ? editMode(snapshot.data ?? "")
          : readOnlyMode(snapshot.data ?? ""),
    );
  }

  Widget readOnlyMode(String text) {
    Widget widget = Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(text),
    );
    if (hovering) {
      widget = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget,
          _EditIcon(onClick: () => setState(() {
            editing = true;
            tmpText = text;
          })),
        ],
      );
    }
    return MouseRegion(
      onEnter: (event) => setState(() {
        hovering = true;
      }),
      onExit: (event) => setState(() {
        hovering = false;
      }),
      child: Padding(
        padding: EdgeInsets.only(right: 12),
        child: widget,
      ),
    );
  }

  Widget editMode(String text) {
    var confirm = () => setState(() {
      editing = false;
      hovering = false;
      widget.onSave(tmpText).catchError((error) => widget.onError(error));
    });
    var handler = (event) {
      if (event.physicalKey == PhysicalKeyboardKey.enter) {
        confirm();
      }
      return false;
    };
    ServicesBinding.instance.keyboard.addHandler(handler);
    // TODO: figure out a way to remove the handler
    var buttons = [
      _ConfirmIcon(onClick: confirm),
      _CancelIcon(onClick: () => setState(() {
        editing = false;
        hovering = false;
      })),
    ];
    return Expanded(child: TextFormField(
      initialValue: text,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: buttons,
        ),
      ),
      onChanged: (value) {
        tmpText = value;
      },
    ));
  }
}

class HoverIcon extends StatefulWidget {
  final IconData defaultIcon;
  final IconData onHoverIcon;

  const HoverIcon({super.key, required this.defaultIcon, required this.onHoverIcon});

  @override
  State<StatefulWidget> createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() {
        hovering = true;
      }),
      onExit: (e) => setState(() {
        hovering = false;
      }),
      child: hovering ? Icon(widget.onHoverIcon) : Icon(widget.defaultIcon),
    );
  }
}

class _EditIcon extends StatelessWidget {
  final Function() onClick;

  const _EditIcon({required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onClick, child: Icon(Icons.edit, size: 16,));
  }
}

class _ConfirmIcon extends StatelessWidget {
  final Function() onClick;

  const _ConfirmIcon({required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: HoverIcon(
        defaultIcon: Icons.check_circle_outline,
        onHoverIcon: Icons.check_circle,
      ),
    );
  }
}

class _CancelIcon extends StatelessWidget {
  final Function() onClick;

  const _CancelIcon({required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: HoverIcon(
        defaultIcon: Icons.cancel_outlined,
        onHoverIcon: Icons.cancel,
      ),
    );
  }
}
