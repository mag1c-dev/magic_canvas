import 'dart:math';
import 'dart:ui';

extension ListUtil<E> on List<E> {
  E? firstWhereNullable(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  E? lastWhereNullable(bool Function(E element) test) {
    late E result;
    bool foundMatching = false;
    for (E element in this) {
      if (test(element)) {
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    return null;
  }
}

extension OffsetExt on Offset {
  double distanceTo(Offset offset) {
    return sqrt(pow((offset.dx - dx), 2) + pow((offset.dy - dy), 2));
  }

  double distanceToLine(Offset lineStart, Offset lineEnd) {
    double a = this.dx - lineStart.dx;
    double b = this.dy - lineStart.dy;
    double c = lineEnd.dx - lineStart.dx;
    double d = lineEnd.dy - lineStart.dy;

    double dot = a * c + b * d;
    double lenSq = c * c + d * d;
    double param = (lenSq != 0) ? dot / lenSq : -1;

    double xx, yy;

    if (param < 0) {
      xx = lineStart.dx;
      yy = lineStart.dy;
    } else if (param > 1) {
      xx = lineEnd.dx;
      yy = lineEnd.dy;
    } else {
      xx = lineStart.dx + param * c;
      yy = lineStart.dy + param * d;
    }

    double dx = this.dx - xx;
    double dy = this.dy - yy;

    return sqrt(dx * dx + dy * dy);
  }

  Offset rotate({Offset center = Offset.zero, double angle = 0}) {
    final double x = center.dx +
        (dx - center.dx) * cos(angle) -
        (dy - center.dy) * sin(angle);
    final double y = center.dy +
        (dx - center.dx) * sin(angle) +
        (dy - center.dy) * cos(angle);
    return Offset(x, y);
  }

  bool isPointInsideTriangle(Offset vertexA, Offset vertexB, Offset vertexC) {
    double alpha = ((vertexB.dy - vertexC.dy) * (dx - vertexC.dx) +
            (vertexC.dx - vertexB.dx) * (dy - vertexC.dy)) /
        ((vertexB.dy - vertexC.dy) * (vertexA.dx - vertexC.dx) +
            (vertexC.dx - vertexB.dx) * (vertexA.dy - vertexC.dy));

    double beta = ((vertexC.dy - vertexA.dy) * (dx - vertexC.dx) +
            (vertexA.dx - vertexC.dx) * (dy - vertexC.dy)) /
        ((vertexB.dy - vertexC.dy) * (vertexA.dx - vertexC.dx) +
            (vertexC.dx - vertexB.dx) * (vertexA.dy - vertexC.dy));

    double gamma = 1.0 - alpha - beta;

    return alpha > 0 && beta > 0 && gamma > 0;
  }

  //Function to check if a point is inside an oval (ellipse)
  bool isPointInsideOval(
      Offset ovalCenter, double semiMajorAxis, double semiMinorAxis) {
    double xTerm = (dx - ovalCenter.dx) / semiMajorAxis;
    double yTerm = (dy - ovalCenter.dy) / semiMinorAxis;

    return (xTerm * xTerm + yTerm * yTerm) <= 1;
  }
}
