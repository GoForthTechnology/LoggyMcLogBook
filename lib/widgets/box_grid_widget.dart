import 'package:fc_forms/src/follow_up_form/models/form_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

class BoxGridWidget extends StatelessWidget {
  final List<GridRow> rows;
  final Row? headerRow;
  final int nColumns;
  final bool includeRowLabels;

  static Row? basicHeaderRow(int nColumns) {
    List<Widget> columnHeadings = [];
    for (int i = 0; i < nColumns; i++) {
      columnHeadings.add(LegendCell(
        text: (i + 1).toString(),
        width: 30,
      ));
    }
    return Row(children: columnHeadings);
  }

  static Row? explanationHeaderRow() {
    return const Row(children: [LegendCell(text: "", width: 30)]);
  }

  const BoxGridWidget({
    super.key,
    required this.headerRow,
    required this.rows,
    this.nColumns = 8,
    this.includeRowLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> gridRows = [];

    if (headerRow != null) {
      gridRows.add(headerRow!);
    }
    gridRows.addAll(rows.map((r) => Row(children: r.cells)));
    Widget grid = Stack(clipBehavior: Clip.none, children: [
      Positioned(
        left: 5,
        top: 5 + (headerRow != null ? 30 : 0),
        child: Container(
          width: 30.0 * nColumns,
          height: 30.0 * rows.length,
          color: Colors.black,
        ),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: gridRows),
    ]);

    List<Widget> labels = [];
    if (includeRowLabels) {
      if (headerRow != null) {
        labels.add(const LegendCell(
          text: "",
          width: 40,
        ));
      }
      for (int i = 0; i < rows.length; i++) {
        labels.add(LegendCell(
          text: rows[i].rowLabel,
          width: 40,
        ));
      }
    }
    return Column(
      children: [
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(children: labels),
            grid,
          ],
        ),
        const Spacer(),
      ],
    );
  }
}

class GridRow {
  final String rowLabel;
  final List<Widget> cells;

  GridRow(FollowUpFormItem item, int itemIndex,
      void Function(BuildContext, int, int) showDialogFn,
      {int numColumns = 8})
      : cells = List.generate(
            numColumns,
            (index) => BoxWidget(showDialogFn, item, itemIndex, index,
                disabled: item.disabledCells.contains(index))),
        rowLabel = createRowLabel(item);

  static String createRowLabel(FollowUpFormItem item) {
    if (item.subSection == "") {
      return "";
    }
    return "${item.section}${item.superSection ?? ""}${item.subSection}${item.subSubSection ?? ""}";
  }
}

class LegendCell extends StatelessWidget {
  final String text;
  final double width;

  const LegendCell({super.key, required this.text, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 30,
      child: Align(alignment: Alignment.center, child: Text(text)),
    );
  }
}

class BoxWidget extends StatelessWidget {
  final void Function(BuildContext, int, int) showDialogFn;
  final FollowUpFormItem item;
  final int itemIndex;
  final int followUpIndex;
  final bool disabled;

  const BoxWidget(
      this.showDialogFn, this.item, this.itemIndex, this.followUpIndex,
      {super.key, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: disabled
            ? null
            : () {
                showDialogFn(context, itemIndex, followUpIndex);
              },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: disabled ? Colors.grey[300] : Colors.white,
          ),
          width: 30,
          height: 30,
          child: item.questions.length > 1
              ? CustomPaint(
                  painter: CellPainter(
                    leftValue: "",
                    rightValue: "",
                  ),
                )
              : Center(child: Text("")),
        ));
  }
}

class CellPainter extends CustomPainter {
  final String leftValue;
  final String rightValue;

  CellPainter({required this.leftValue, required this.rightValue});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.black;
    if (leftValue.isNotEmpty) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: leftValue,
          style: GoogleFonts.sourceSans3(),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(canvas, const Offset(5, 0));
    }
    if (rightValue.isNotEmpty) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: rightValue,
          style: GoogleFonts.sourceSans3(),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(canvas, const Offset(15, 10));
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
