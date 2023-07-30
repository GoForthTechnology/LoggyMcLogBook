import 'package:flutter/material.dart';

enum OverviewAttentionLevel {
 INFO, WARNING, ERROR;

 get fillColor {
   switch (this) {
     case OverviewAttentionLevel.INFO:
       return Color.fromRGBO(239, 239, 239, 1.0);
     case OverviewAttentionLevel.WARNING:
       return Color.fromRGBO(253, 242, 208, 1.0);
     case OverviewAttentionLevel.ERROR:
       return Color.fromRGBO(238, 205, 205, 1.0);
   }
 }

 get borderColor {
  switch (this) {
    case OverviewAttentionLevel.INFO:
      return Color.fromRGBO(183, 183, 183, 1.0);
    case OverviewAttentionLevel.WARNING:
      return Color.fromRGBO(234, 196, 81, 1.0);
    case OverviewAttentionLevel.ERROR:
      return Color.fromRGBO(187, 39, 26, 1.0);
  }
 }
}

class OverviewTile extends StatelessWidget {
  final OverviewAttentionLevel attentionLevel;
  final String title;
  final List<StatelessWidget> content;
  final Function() onClick;

  const OverviewTile({
    super.key,
    required this.attentionLevel,
    required this.title,
    required this.content,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onClick, child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: attentionLevel.borderColor, width: 2),
        color: attentionLevel.fillColor,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        const Spacer(),
      ] + content),
    ));
  }
}
