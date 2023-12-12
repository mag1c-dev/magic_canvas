/// This is a Dart code file named image_shape.dart.
///
/// Summary:
/// This file defines a class called ImageShape, which is a subclass of TextBoxShape. It represents a shape that displays an image.
/// The ImageShape class has properties for the image, border color, background color, location, size, text, text alignment, text style, z-index, and border radius.
/// The constructor initializes the properties of the ImageShape object, including setting the size based on the dimensions of the image.
/// The drawObject method overrides the parent class's method to draw the image on the canvas using the provided paint object.

import 'dart:ui';
import 'package:magic_canvas/shape/shape.dart';

class ImageShape extends TextBoxShape {
  Image image;

  ImageShape({
    required this.image,
    super.borderColor,
    super.color,
    super.location,
    super.size,
    super.text,
    super.textAlign,
    super.textStyle,
    super.zIndex,
    super.borderRadius,
    super.reactSize,
  }) {
    size = Size(image.width.toDouble(), image.height.toDouble());
  }

  @override
  void drawObject(Canvas canvas, Paint paint) async {
    super.drawObject(canvas, paint);

    canvas.drawImageNine(
        image,
        Rect.zero,
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        paint);
  }
}
