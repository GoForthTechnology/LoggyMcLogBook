

import 'package:flutter/material.dart';
import 'package:lmlb/widgets/overview_tile.dart';

class AppointmentOverviewWidget extends StatelessWidget {

  final String title;
  final String subtitle;
  final OverviewAttentionLevel attentionLevel;

  const AppointmentOverviewWidget({super.key, required this.attentionLevel, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return OverviewTile(
      attentionLevel: this.attentionLevel,
      title: title,
      subtitle: subtitle,
      icon: Icons.event,
      onClick: () => {},
    );
  }
}