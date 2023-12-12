/// This is a Dart file named line_shape.dart.
/// It contains the implementation of the LineShape class, which is a subclass of AbstractShape.
/// The LineShape represents a line on a canvas with specified length, width, location, color, and style.
/// It can be drawn on a canvas and has functionality for resizing, removing, and translating.
/// The LineShape also has methods for checking if a point is over the line and getting the start and end offsets.
/// This code is written in the Dart programming language.

import 'package:flutter/material.dart';
import 'package:magic_canvas/utils/extension.dart';
import 'package:magic_canvas/shape/shape.dart';

class LineShape extends AbstractShape {
  LineShape({
    double length = 150,
    double width = 4,
    super.location,
    super.color,
    super.zIndex,
    this.style = PaintingStyle.stroke,
    super.reactSize,
  }) {
    _endOffset = location.translate(length, 0);
    super.size = Size(length, width);
  }

  PaintingStyle style;
  late Offset _endOffset;

  @override
  void draw(Canvas canvas, Size boardSize) {
    /// Draw the line shape on the canvas
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..style = style;

    Path path = Path();
    path.moveTo(location.dx, location.dy);
    path.lineTo(_endOffset.dx, _endOffset.dy);
    canvas.drawPath(path, paint);

    /// Highlight or select the line shape if necessary
    if (isHighlight || isSelected) {
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    /// Draw resize points and remove points if the line shape is selected
    if (isSelected) {
      for (var resizePoint in resizePoints) {
        paint.color = Colors.blue;
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(resizePoint.offset.dx, resizePoint.offset.dy),
          5,
          paint,
        );
      }
      for (var removePoint in removePoints) {
        const icon = Icons.remove_circle;
        TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, removePoint.translate(-10, -10));
      }
    }
  }

  @override
  List<ResizePoint> get resizePoints => [
        ResizePoint(
          offset: startOffset,
          onResize: (oldMouse, newMouse) {
            location = newMouse;
          },
        ),
        ResizePoint(
          offset: endOffset,
          onResize: (oldMouse, newMouse) {
            _endOffset = newMouse;
          },
        ),
      ];

  @override
  List<Offset> get removePoints => [
        location.translate(0, -20),
      ];

  @override
  void translate(Offset oldOffset, Offset newOffset) {
    final deltaX = newOffset.dx - oldOffset.dx;
    final deltaY = newOffset.dy - oldOffset.dy;
    location = location.translate(deltaX, deltaY);
    _endOffset = _endOffset.translate(deltaX, deltaY);
  }

  @override
  bool isOverObject(Offset offset) {
    return offset.distanceToLine(location, _endOffset) < 10;
  }

  Offset get startOffset => location;

  Offset get endOffset => _endOffset;
}
