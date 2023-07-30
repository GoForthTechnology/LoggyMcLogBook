

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/widgets/overview_tile.dart';

class AppointmentOverviewWidget extends StatelessWidget {

  static Random r = Random();

  @override
  Widget build(BuildContext context) {
    return OverviewTile(
      attentionLevel: r.nextDouble() < 0.5 ? OverviewAttentionLevel.INFO : r.nextDouble() < 0.5 ? OverviewAttentionLevel.WARNING : OverviewAttentionLevel.ERROR,
      title: "Appointments",
      content: [],
      onClick: () => {},
    );
  }
}