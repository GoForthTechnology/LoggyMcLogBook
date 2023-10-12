import 'package:flutter/material.dart';

enum OverviewAttentionLevel {
  GREEN, GREY, YELLOW, RED;

 get fillColor {
   switch (this) {
     case OverviewAttentionLevel.GREEN:
       return Color.fromRGBO(220, 233, 213, 1.0);
     case OverviewAttentionLevel.GREY:
       return Color.fromRGBO(239, 239, 239, 1.0);
     case OverviewAttentionLevel.YELLOW:
       return Color.fromRGBO(253, 242, 208, 1.0);
     case OverviewAttentionLevel.RED:
       return Color.fromRGBO(238, 205, 205, 1.0);
   }
 }

 get borderColor {
  switch (this) {
    case OverviewAttentionLevel.GREEN:
      return Color.fromRGBO(120, 166, 90, 1.0);
    case OverviewAttentionLevel.GREY:
      return Color.fromRGBO(183, 183, 183, 1.0);
    case OverviewAttentionLevel.YELLOW:
      return Color.fromRGBO(234, 196, 81, 1.0);
    case OverviewAttentionLevel.RED:
      return Color.fromRGBO(187, 39, 26, 1.0);
  }
 }
}

class OverviewAction {
  final String title;
  final Function()? onPress;

  OverviewAction({required this.title, this.onPress});
}

class OverviewTile extends StatelessWidget {
  final OverviewAttentionLevel attentionLevel;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Function()? onClick;
  final List<OverviewAction> actions;

  const OverviewTile({
    super.key,
    required this.attentionLevel,
    required this.title,
    required this.icon,
    this.onClick,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    var actions = this.actions.map((a) => Container(
      margin: EdgeInsets.only(left: 8),
      child: TextButton(
        child: Text(a.title.toUpperCase()),
        onPressed: a.onPress,
      ),
    )).toList();
    var listTile = ListTile(
      leading: Icon(this.icon, color: attentionLevel.borderColor,),
      title: Text(this.title),
      subtitle: this.subtitle != null ? Text(this.subtitle!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions,
      )
    );
    Widget card = Card(
      color: attentionLevel.fillColor,
      elevation: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          listTile,
        ],
      ),
    );
    if (onClick != null) {
      card = GestureDetector(onTap: onClick, child: card);
    }
    return card;
  }
}
