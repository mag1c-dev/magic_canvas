import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magic_canvas/utils/extension.dart';

typedef ResizeCallback = Function(Offset oldMouse, Offset newMouse);

class RotatePoint {
  final Offset offset;
  final Offset anchorOffset;

  const RotatePoint( {
    this.offset = Offset.zero,
    this.anchorOffset = Offset.zero,
  });
}

class ResizePoint {
  final Offset offset;
  final ResizeCallback? onResize;

  const ResizePoint({
    this.offset = Offset.zero,
    this.onResize,
  });
}


abstract class AbstractShape {
  Offset location;
  Size size;
  Color color;

  int zIndex;
  int reactSize;

  double _angle = 0;

  bool _isHighlight = false;
  bool _isDragging = false;
  bool _isResizing = false;
  bool _isRotating = false;
  bool _isSelected = false;

  ResizePoint? _activeResizePoint;
  RotatePoint? _activeRotatePoint;

  AbstractShape({
    this.location = const Offset(0, 0),
    this.size = const Size(20, 20),
    this.color = Colors.grey,
    this.zIndex = 0,
    this.reactSize = 10,
  });

  void draw(Canvas canvas, Size boardSize);

  void resize(Offset oldOffset, Offset newOffset) {
    activeResizePoint?.onResize?.call(oldOffset, newOffset);
  }

  void rotate(Offset oldOffset, Offset newOffset) {
    if (_activeRotatePoint != null) {
      _angle += _calculateAngleBetweenLines(oldOffset, center, newOffset, center);
    }
  }

  double _calculateAngleBetweenLines(Offset point1, Offset point2, Offset point3, Offset point4) {
    double vector1x = point2.dx - point1.dx;
    double vector1y = point2.dy - point1.dy;
    double vector2x = point4.dx - point3.dx;
    double vector2y = point4.dy - point3.dy;
    double angle = atan2(vector2y, vector2x) - atan2(vector1y, vector1x);
    return angle;
  }

  void translate(Offset oldOffset, Offset newOffset) {
    final deltaX = newOffset.dx - oldOffset.dx;
    final deltaY = newOffset.dy - oldOffset.dy;
    location = location.translate(deltaX, deltaY);
  }

  bool shouldRepaint(covariant AbstractShape oldDelegate) {
    return true;
  }

  void selected() {
    _isSelected = true;
  }

  void deSelected() {
    _isSelected = false;
  }

  void startResize(ResizePoint resizePoint) {
    _activeResizePoint = resizePoint;
    _isResizing = true;
  }

  void endResize() {
    _activeResizePoint = null;
    _isResizing = false;
  }

  void startDrag() {
    _isDragging = true;
  }

  void endDrag() {
    _isDragging = false;
  }

  void startRotate(RotatePoint rotatePoint) {
    _activeRotatePoint = rotatePoint;
    _isRotating = true;
  }

  void endRotate() {
    _activeRotatePoint = null;
    _isRotating = false;
  }

  void highlight() {
    _isHighlight = true;
  }

  void unHighlight() {
    _isHighlight = false;
  }

  void changeZIndex(int index) {
    zIndex = index;
  }

  bool isOverResizePoint(Offset mouseOffset) {
    return overResizePoint(mouseOffset) != null;
  }

  bool isOverRotatePoint(Offset mouseOffset) {
    return overRotatePoint(mouseOffset) != null;
  }

  bool isOverRemovePoint(Offset mouseOffset) {
    return overRemovePoint(mouseOffset) != null;
  }

  bool isOverObject(Offset offset) {
    return Rect.fromPoints(
      location,
      location.translate(
        size.width,
        size.height,
      ),
    ).contains(offset);
  }

  ResizePoint? overResizePoint(Offset mouseOffset) {
    double minDistance = double.infinity;
    ResizePoint? minPoint;
    for (var element in resizePoints) {
      double distance = element.offset.distanceTo(mouseOffset);
      if (distance < reactSize && distance < minDistance) {
        minDistance = distance;
        minPoint = element;
      }
    }
    return minPoint;
  }

  RotatePoint? overRotatePoint(Offset mouseOffset) {
    return rotatePoints.firstWhereNullable((RotatePoint element) => element.offset.distanceTo(mouseOffset) < reactSize);
  }

  Offset? overRemovePoint(Offset mouseOffset) {
    return removePoints.firstWhereNullable((Offset element) => element.distanceTo(mouseOffset) < reactSize);
  }

  bool get isHighlight => _isHighlight;

  bool get isResizing => _isResizing;

  bool get isDragging => _isDragging;

  bool get isRotating => _isRotating;

  bool get isSelected => _isSelected;

  double get angle => _angle;

  Offset get center => location.translate(size.width / 2, size.height / 2);

  List<ResizePoint> get resizePoints => [];

  List<RotatePoint> get rotatePoints => [];

  List<Offset> get removePoints => [];

  ResizePoint? get activeResizePoint => _activeResizePoint;

  RotatePoint? get activeRotatePoint => _activeRotatePoint;
}


