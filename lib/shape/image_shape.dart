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
