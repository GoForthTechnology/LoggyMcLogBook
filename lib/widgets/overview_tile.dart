import 'package:flutter/material.dart';

enum OverviewAttentionLevel {
  green,
  grey,
  yellow,
  red;

  get fillColor {
    switch (this) {
      case OverviewAttentionLevel.green:
        return const Color.fromRGBO(220, 233, 213, 1.0);
      case OverviewAttentionLevel.grey:
        return const Color.fromRGBO(239, 239, 239, 1.0);
      case OverviewAttentionLevel.yellow:
        return const Color.fromRGBO(253, 242, 208, 1.0);
      case OverviewAttentionLevel.red:
        return const Color.fromRGBO(238, 205, 205, 1.0);
    }
  }

  get borderColor {
    switch (this) {
      case OverviewAttentionLevel.green:
        return const Color.fromRGBO(120, 166, 90, 1.0);
      case OverviewAttentionLevel.grey:
        return const Color.fromRGBO(183, 183, 183, 1.0);
      case OverviewAttentionLevel.yellow:
        return const Color.fromRGBO(234, 196, 81, 1.0);
      case OverviewAttentionLevel.red:
        return const Color.fromRGBO(187, 39, 26, 1.0);
    }
  }
}

class OverviewAction {
  final String title;
  final Function()? onPress;

  OverviewAction({required this.title, this.onPress});
}

class OverviewTile extends StatelessWidget implements Comparable<OverviewTile> {
  final OverviewAttentionLevel attentionLevel;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Function()? onClick;
  final List<OverviewAction> actions;
  final List<Widget> additionalTrailing;
  final Comparable comparable;

  const OverviewTile({
    super.key,
    required this.attentionLevel,
    required this.title,
    required this.icon,
    this.comparable = "",
    this.onClick,
    this.subtitle,
    this.actions = const [],
    this.additionalTrailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = this
        .actions
        .map((a) => Container(
              margin: const EdgeInsets.only(left: 8),
              child: TextButton(
                onPressed: a.onPress,
                child: Text(a.title.toUpperCase()),
              ),
            ))
        .toList();
    var listTile = ListTile(
        leading: Icon(
          icon,
          color: attentionLevel.borderColor,
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [...additionalTrailing, ...actions],
        ));
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

  @override
  int compareTo(OverviewTile other) {
    return comparable.compareTo(other.comparable);
  }
}
