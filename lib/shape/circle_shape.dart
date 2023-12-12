/// This is a Dart code file named circle_shape.dart.
/// It contains the implementation of a CircleShape class which extends the TextBoxShape class.
/// The CircleShape class represents a circular shape with customizable properties such as location, size, color, border, and text.
/// It overrides the drawObject, drawDecorate, and isOverObject methods to provide specific functionality for drawing and interaction.
/// The drawObject method draws the circle shape on the canvas using the provided paint object.
/// The drawDecorate method is responsible for drawing the border of the circle shape if a border color is specified.
/// The isOverObject method checks if a given offset is inside the circle shape.
/// Overall, this code provides a way to create and manipulate circle shapes in a canvas.
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
