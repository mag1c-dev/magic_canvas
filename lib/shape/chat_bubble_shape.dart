/// This is a Dart code from the file chat_bubble_shape.dart.
/// It defines a class ChatBubbleShape that extends TextBoxShape.
/// The ChatBubbleShape represents a chat bubble shape with an optional arrow pointing to a specific location.
/// It provides methods to draw the chat bubble shape, draw the highlight when selected or highlighted, and draw the border decoration.
/// The class also handles resizing and translation of the chat bubble shape.
/// The programming language used is Dart.

import 'package:flutter/material.dart';
import 'package:magic_canvas/utils/extension.dart';
import 'package:magic_canvas/shape/shape.dart';

class ChatBubbleShape extends TextBoxShape {
  ChatBubbleShape({
    Offset? arrowPoint,
    super.location,
    super.size,
    super.color,
    super.zIndex,
    super.text,
    super.textAlign,
    super.textStyle,
    super.borderColor,
    super.borderRadius,
    super.reactSize,
  }) {
    this.arrowPoint = arrowPoint ?? location.translate(30, size.height + 50);
  }

  late Offset arrowPoint;

  List<Offset>? get arrowFoot {
    if (arrowPoint.dy < location.dy) {
      if (arrowPoint.dx < center.dx) {
        return [
          Offset(location.dx + size.width / 5, location.dy),
          Offset(location.dx + size.width * 2 / 5, location.dy),
        ];
      } else {
        return [
          Offset(location.dx + size.width * 3 / 5, location.dy),
          Offset(location.dx + size.width * 4 / 5, location.dy),
        ];
      }
    }
    if (arrowPoint.dy > location.dy + size.height) {
      if (arrowPoint.dx < center.dx) {
        return [
          Offset(location.dx + size.width * 2 / 5, location.dy + size.height),
          Offset(location.dx + size.width / 5, location.dy + size.height),
        ];
      } else {
        return [
          Offset(location.dx + size.width * 4 / 5, location.dy + size.height),
          Offset(location.dx + size.width * 3 / 5, location.dy + size.height),
        ];
      }
    }
    if (arrowPoint.dx < location.dx) {
      if (arrowPoint.dy < center.dy) {
        return [
          Offset(location.dx, location.dy + size.height * 2 / 5),
          Offset(location.dx, location.dy + size.height / 5),
        ];
      } else {
        return [
          Offset(location.dx, location.dy + size.height * 4 / 5),
          Offset(location.dx, location.dy + size.height * 3 / 5),
        ];
      }
    }
    if (arrowPoint.dx > location.dx + size.width) {
      if (arrowPoint.dy < center.dy) {
        return [
          Offset(location.dx + size.width, location.dy + size.height / 5),
          Offset(location.dx + size.width, location.dy + size.height * 2 / 5),
        ];
      } else {
        return [
          Offset(location.dx + size.width, location.dy + size.height * 3 / 5),
          Offset(location.dx + size.width, location.dy + size.height * 4 / 5),
        ];
      }
    }
    return null;
  }

  @override
  void drawObject(Canvas canvas, Paint paint) {
    if (arrowFoot == null) {
      super.drawObject(canvas, paint);
    } else {
      var path = Path();
      path.moveTo(location.dx + borderRadius.x, location.dy);
      if (arrowFoot![0]
              .distanceToLine(location, location.translate(size.width, 0)) <
          5) {
        _drawArrow(path);
      }
      path.lineTo(location.dx + size.width - borderRadius.x, location.dy);
      path.arcToPoint(
          Offset(location.dx + size.width, location.dy + borderRadius.y),
          radius: borderRadius);
      if (arrowFoot![0].distanceToLine(location.translate(size.width, 0),
              location.translate(size.width, size.height)) <
          5) {
        _drawArrow(path);
      }
      path.lineTo(
          location.dx + size.width, location.dy + size.height - borderRadius.y);
      path.arcToPoint(
          Offset(location.dx + size.width - borderRadius.x,
              location.dy + size.height),
          radius: borderRadius);
      if (arrowFoot![0].distanceToLine(
              location.translate(size.width, size.height),
              location.translate(0, size.height)) <
          5) {
        _drawArrow(path);
      }
      path.lineTo(location.dx + borderRadius.x, location.dy + size.height);
      path.arcToPoint(
          Offset(location.dx, location.dy + size.height - borderRadius.y),
          radius: borderRadius);
      if (arrowFoot![0]
              .distanceToLine(location.translate(0, size.height), location) <
          5) {
        _drawArrow(path);
      }
      path.lineTo(location.dx, location.dy + borderRadius.y);
      path.arcToPoint(Offset(location.dx + borderRadius.x, location.dy),
          radius: borderRadius);
      canvas.drawPath(path, paint);
    }
  }

  void _drawArrow(Path path) {
    path.lineTo(arrowFoot![0].dx, arrowFoot![0].dy);
    path.lineTo(arrowPoint.dx, arrowPoint.dy);
    path.lineTo(arrowFoot![1].dx, arrowFoot![1].dy);
  }

  @override
  void drawHighlight(Canvas canvas, Paint paint) {
    if (isHighlight || isSelected) {
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.blue;
      drawObject(canvas, paint);
    }
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
  List<ResizePoint> get resizePoints => [
        ...super.resizePoints,
        ResizePoint(
          offset: arrowPoint,
          onResize: (oldMouse, newMouse) {
            arrowPoint = newMouse.rotate(center: center, angle: -angle);
          },
        ),
      ];

  @override
  void translate(Offset oldOffset, Offset newOffset) {
    final deltaX = newOffset.dx - oldOffset.dx;
    final deltaY = newOffset.dy - oldOffset.dy;
    location = location.translate(deltaX, deltaY);
    arrowPoint = arrowPoint.translate(deltaX, deltaY);
  }

  @override
  bool isOverObject(Offset offset) {
    return super.isOverObject(offset) ||
        (arrowFoot != null &&
            offset.isPointInsideTriangle(
                arrowFoot![0], arrowFoot![1], arrowPoint));
  }
}
