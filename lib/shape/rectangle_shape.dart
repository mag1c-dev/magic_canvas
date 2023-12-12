/// This file contains the implementation of the RectangleShape class, which is a subclass of AbstractShape.
/// It represents a rectangular shape with customizable properties such as border color and border radius.
/// The class provides methods to draw the shape on a canvas, including highlighting, decorating, and handling interactive points.
/// It also defines the positions and behaviors of resize and remove points for the shape.

import 'package:flutter/material.dart';
import 'package:magic_canvas/utils/extension.dart';
import 'package:magic_canvas/shape/shape.dart';

class RectangleShape extends AbstractShape {
  Color? borderColor;
  Radius borderRadius;

  RectangleShape({
    this.borderColor,
    this.borderRadius = Radius.zero,
    super.location,
    super.size,
    super.color,
    super.zIndex,
    super.reactSize,
  });

  @override
  void draw(Canvas canvas, Size boardSize) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    drawObject(canvas, paint);
    drawDecorate(canvas, paint);
    drawHighlight(canvas, paint);
    drawInteractivePoint(canvas, paint);
  }

  void drawHighlight(Canvas canvas, Paint paint) {
    if (isHighlight || isSelected) {
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      canvas.drawRect(
        Rect.fromPoints(
          location,
          location.translate(size.width, size.height),
        ),
        paint,
      );
    }
  }

  void drawObject(Canvas canvas, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromPoints(
            location,
            location.translate(size.width, size.height),
          ),
          borderRadius),
      paint,
    );
  }

  void drawDecorate(Canvas canvas, Paint paint) {
    if (borderColor != null) {
      paint.color = borderColor!;
      paint.style = PaintingStyle.stroke;
      drawObject(canvas, paint);
    }
  }

  void drawInteractivePoint(Canvas canvas, Paint paint) {
    if (isSelected) {
      for (var resizePoint in resizePoints) {
        paint.color = Colors.blue;
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          resizePoint.offset,
          5,
          paint,
        );
      }
      for (var rotatePoint in rotatePoints) {
        paint.color = Colors.blue;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1;
        canvas.drawLine(
          rotatePoint.offset,
          rotatePoint.anchorOffset,
          paint,
        );
        const icon = Icons.rotate_right;
        TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, rotatePoint.offset.translate(-10, -10));
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
  List<RotatePoint> get rotatePoints => [
        RotatePoint(
          offset: location.translate(size.width / 2, -30),
          anchorOffset: location.translate(size.width / 2, 0),
        ),
      ];

  @override
  List<ResizePoint> get resizePoints => [
        //middle left
        ResizePoint(
          offset: location.translate(0, size.height / 2),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTR = location
                .translate(size.width, 0)
                .rotate(center: center, angle: angle);
            Offset newMouseDeRotated =
                newMouse.rotate(center: center, angle: -angle);
            Offset rotatedBL =
                Offset(newMouseDeRotated.dx, location.dy + size.height)
                    .rotate(angle: angle, center: center);
            Size newSize = Size(
                location.dx + size.width - newMouseDeRotated.dx, size.height);
            Offset newCenter = Offset(
              (rotatedTR.dx + rotatedBL.dx) / 2,
              (rotatedTR.dy + rotatedBL.dy) / 2,
            );

            Offset newTR = rotatedTR.rotate(
              center: newCenter,
              angle: -angle,
            );
            size = newSize;
            location = newTR.translate(-size.width, 0);
          },
        ),
        //middle top
        ResizePoint(
          offset: location.translate(size.width / 2, 0),
          onResize: (oldMouse, newMouse) {
            Offset rotatedBL = location
                .translate(0, size.height)
                .rotate(center: center, angle: angle);
            Offset newMouseDeRotated =
                newMouse.rotate(center: center, angle: -angle);
            Offset rotatedTR =
                Offset(location.dx + size.width, newMouseDeRotated.dy)
                    .rotate(angle: angle, center: center);
            Size newSize = Size(
                size.width, location.dy + size.height - newMouseDeRotated.dy);
            Offset newCenter = Offset(
              (rotatedBL.dx + rotatedTR.dx) / 2,
              (rotatedBL.dy + rotatedTR.dy) / 2,
            );
            Offset newBL = rotatedBL.rotate(
              center: newCenter,
              angle: -angle,
            );
            size = newSize;
            location = newBL.translate(0, -size.height);
          },
        ),

        //middle right
        ResizePoint(
          offset: location.translate(size.width, size.height / 2),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTL = location.rotate(center: center, angle: angle);
            Offset newMouseDeRotated =
                newMouse.rotate(center: center, angle: -angle);
            Offset rotatedBR =
                Offset(newMouseDeRotated.dx, location.dy + size.height)
                    .rotate(angle: angle, center: center);
            Size newSize =
                Size(newMouseDeRotated.dx - location.dx, size.height);
            Offset newCenter = Offset(
              (rotatedTL.dx + rotatedBR.dx) / 2,
              (rotatedTL.dy + rotatedBR.dy) / 2,
            );
            Offset newTL = rotatedTL.rotate(
              center: newCenter,
              angle: -angle,
            );
            size = newSize;
            location = newTL;
          },
        ),
        //middle bottom
        ResizePoint(
          offset: location.translate(size.width / 2, size.height),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTL = location.rotate(center: center, angle: angle);
            Offset newMouseDeRotated =
                newMouse.rotate(center: center, angle: -angle);
            Offset rotatedBR =
                Offset(location.dx + size.width, newMouseDeRotated.dy)
                    .rotate(angle: angle, center: center);
            Size newSize = Size(size.width, newMouseDeRotated.dy - location.dy);
            Offset newCenter = Offset(
              (rotatedTL.dx + rotatedBR.dx) / 2,
              (rotatedTL.dy + rotatedBR.dy) / 2,
            );
            Offset newTL = rotatedTL.rotate(
              center: newCenter,
              angle: -angle,
            );
            size = newSize;
            location = newTL;
          },
        ),
        //top left
        ResizePoint(
          offset: location,
          onResize: (oldMouse, newMouse) {
            Offset rotatedBR = location
                .translate(size.width, size.height)
                .rotate(center: center, angle: angle);

            Offset newCenter = Offset(
              (rotatedBR.dx + newMouse.dx) / 2,
              (rotatedBR.dy + newMouse.dy) / 2,
            );

            Offset newTL = newMouse.rotate(
              center: newCenter,
              angle: -angle,
            );

            Offset newBR = rotatedBR.rotate(center: newCenter, angle: -angle);
            location = newTL;
            size = Size(newBR.dx - newTL.dx, newBR.dy - newTL.dy);
          },
        ),
        //top right
        ResizePoint(
          offset: location.translate(size.width, 0),
          onResize: (oldMouse, newMouse) {
            Offset rotatedBL = location
                .translate(0, size.height)
                .rotate(center: center, angle: angle);

            Offset newCenter = Offset(
              (rotatedBL.dx + newMouse.dx) / 2,
              (rotatedBL.dy + newMouse.dy) / 2,
            );

            Offset newTR = newMouse.rotate(
              center: newCenter,
              angle: -angle,
            );
            Offset newBL = rotatedBL.rotate(center: newCenter, angle: -angle);

            location = Offset(newBL.dx, newTR.dy);

            size = Size(newTR.dx - location.dx, newBL.dy - location.dy);
          },
        ),

        //bottom left
        ResizePoint(
          offset: location.translate(0, size.height),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTR = location
                .translate(size.width, 0)
                .rotate(center: center, angle: angle);

            Offset newCenter = Offset(
              (rotatedTR.dx + newMouse.dx) / 2,
              (rotatedTR.dy + newMouse.dy) / 2,
            );

            Offset newBL = newMouse.rotate(
              center: newCenter,
              angle: -angle,
            );
            Offset newTR = rotatedTR.rotate(center: newCenter, angle: -angle);

            location = Offset(newBL.dx, newTR.dy);

            size = Size(newTR.dx - location.dx, newBL.dy - location.dy);
          },
        ),
        //bottom right
        ResizePoint(
          offset: location.translate(size.width, size.height),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTL = location.rotate(center: center, angle: angle);
            Offset newCenter = Offset(
              (rotatedTL.dx + newMouse.dx) / 2,
              (rotatedTL.dy + newMouse.dy) / 2,
            );

            Offset newTL = rotatedTL.rotate(
              center: newCenter,
              angle: -angle,
            );

            Offset newBR = newMouse.rotate(
              center: newCenter,
              angle: -angle,
            );
            location = newTL;
            size = Size(newBR.dx - newTL.dx, newBR.dy - newTL.dy);
          },
        ),
      ];

  @override
  List<Offset> get removePoints => [
        location.translate(size.width + 20, -20),
      ];
}
