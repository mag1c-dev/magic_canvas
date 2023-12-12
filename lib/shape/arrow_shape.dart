import 'dart:math';
import 'package:flutter/material.dart';
import 'package:magic_canvas/shape/shape.dart';

class ArrowShape extends LineShape {
  ArrowShape({
    super.location,
    super.length = 150,
    super.width = 4,
    super.color,
    super.zIndex,
    super.style = PaintingStyle.stroke,
    super.reactSize,
  });

  @override
  void draw(Canvas canvas, Size boardSize) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..style = style;

    var path = Path();
    // Calculate arrowhead points
    double arrowheadLength = 10.0;
    double arrowheadAngle = pi / 6; // 30 degrees

    double angle =
        atan2(endOffset.dy - startOffset.dy, endOffset.dx - startOffset.dx);

    double arrowX1 =
        endOffset.dx - arrowheadLength * cos(angle - arrowheadAngle);
    double arrowY1 =
        endOffset.dy - arrowheadLength * sin(angle - arrowheadAngle);

    double arrowX2 =
        endOffset.dx - arrowheadLength * cos(angle + arrowheadAngle);
    double arrowY2 =
        endOffset.dy - arrowheadLength * sin(angle + arrowheadAngle);

    // Draw arrowhead
    path.moveTo(endOffset.dx, endOffset.dy);
    path.lineTo(arrowX1, arrowY1);
    path.moveTo(endOffset.dx, endOffset.dy);
    path.lineTo(arrowX2, arrowY2);

    // Draw the line
    canvas.drawPath(path, paint);

    if (isHighlight || isSelected) {
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }
    super.draw(canvas, boardSize);
  }
}
