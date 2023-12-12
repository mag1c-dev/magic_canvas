<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Flutter package support draw canvas shapes

[![pub package](https://img.shields.io/pub/v/magic_canvas.svg)](https://pub.dev/packages/magic_canvas)

## Support shapes

1. Rectangle
2. Circle
3. Line
4. Arrow
5. Chat bubble
6. Custom shape by extend AbstractShape

## Getting started

To use this plugin, add `magic_canvas` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Usage

Here is a simple example, see more detail at `/example`

```dart
Board(
    children: [
        RectangleShape(
            borderColor: Colors.red,
            location: const Offset(5, 5),
            size: const Size(30, 50),
            color: Colors.orange,
        ),
        CircleShape(
            borderColor: Colors.red,
            location: const Offset(50, 5),
            size: const Size(30, 50),
            color: Colors.orange,
            text: 'Hello'
        ),
        color: Colors.grey,
        size: const Size(1280, 720),
    ],
)
```

