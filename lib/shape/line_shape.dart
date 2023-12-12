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
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..style = style;

    Path path = Path();
    path.moveTo(location.dx, location.dy);
    path.lineTo(_endOffset.dx, _endOffset.dy);
    canvas.drawPath(path, paint);

    if (isHighlight || isSelected) {
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

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
