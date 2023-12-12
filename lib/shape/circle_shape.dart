import 'dart:math';
import 'dart:ui';
import 'package:magic_canvas/shape/shape.dart';
import 'package:magic_canvas/utils/extension.dart';

class CircleShape extends TextBoxShape {
  CircleShape({
    super.location,
    super.size,
    super.color,
    super.zIndex,
    super.borderColor,
    super.text,
    super.textAlign,
    super.textStyle,
    super.borderRadius,
    super.reactSize,
  });

  @override
  void drawObject(Canvas canvas, Paint paint) {
    canvas.drawOval(
        Rect.fromPoints(
          location,
          location.translate(size.width, size.height),
        ),
        paint);
  }

  @override
  void drawDecorate(Canvas canvas, Paint paint) {
    if (borderColor != null) {
      paint.color = borderColor!;
      paint.style = PaintingStyle.stroke;
      drawObject(canvas, paint);
    }
  }

  @override
  bool isOverObject(Offset offset) {
    double distance1 =
        center.distanceToLine(location, location.translate(size.width, 0));
    double distance2 =
        center.distanceToLine(location, location.translate(0, size.height));
    return offset.isPointInsideOval(
        center, min(distance1, distance2), max(distance1, distance2));
  }
}
