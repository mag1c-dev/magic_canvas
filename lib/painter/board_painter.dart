import 'package:flutter/material.dart';
import '../shape/shape.dart';

class BoardPainter extends CustomPainter {
  final List<AbstractShape>? children;
  final Color? background;

  BoardPainter({
    this.children,
    this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size, 20);
    children?.forEach((element) {
      _drawRotated(
        canvas,
        element.location
            .translate(element.size.width / 2, element.size.height / 2),
        element.angle,
        () => element.draw(canvas, size),
      );
    });
  }

  void _drawRotated(
    Canvas canvas,
    Offset center,
    double angle,
    VoidCallback drawFunction,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    drawFunction();
    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size, double gridSize) {
    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }

    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return children != null &&
        (children!.any((element) => element.shouldRepaint(element)) ||
            children!.isEmpty);
  }
}
