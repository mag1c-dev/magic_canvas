import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:magic_canvas/magic_canvas.dart';

enum Functioning {
  none,
  handing,
  drawRect,
  drawCircle,
  drawChatBubble,
  drawArrow,
  drawLine,
}

class Editor extends StatefulWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  var _functioning = Functioning.none;
  var _showEditTab = false;
  AbstractShape? _selectedShape;
  List<AbstractShape> _children = [];

  final _mouseLocation = StreamController<Offset>.broadcast();

  var boardKey = GlobalKey<BoardState>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _functioning = _functioning == Functioning.handing
                                  ? Functioning.none
                                  : Functioning.handing;
                            });
                          },
                          icon: Icon(
                            Icons.back_hand_sharp,
                            color: _functioning == Functioning.handing
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                      IconButton(
                          onPressed: () async {
                            const XTypeGroup typeGroup = XTypeGroup(
                              label: 'images',
                              extensions: <String>['jpg', 'png'],
                            );
                            final XFile? file = await openFile(
                                acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                            if (file != null) {
                              var imgShape = ImageShape(
                                image: await decodeImageFromList(
                                  await file.readAsBytes(),
                                ),
                              );
                              _children.add(imgShape);
                            }
                          },
                          icon: const Icon(
                            Icons.image,
                            color: Colors.grey,
                          )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _functioning =
                                  _functioning == Functioning.drawRect
                                      ? Functioning.none
                                      : Functioning.drawRect;
                            });
                          },
                          icon: Icon(
                            Icons.rectangle_outlined,
                            color: _functioning == Functioning.drawRect
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _functioning =
                                  _functioning == Functioning.drawCircle
                                      ? Functioning.none
                                      : Functioning.drawCircle;
                            });
                          },
                          icon: Icon(
                            Icons.circle_outlined,
                            color: _functioning == Functioning.drawCircle
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _functioning =
                                  _functioning == Functioning.drawChatBubble
                                      ? Functioning.none
                                      : Functioning.drawChatBubble;
                            });
                          },
                          icon: Icon(
                            Icons.chat_bubble,
                            color: _functioning == Functioning.drawChatBubble
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _functioning =
                                  _functioning == Functioning.drawLine
                                      ? Functioning.none
                                      : Functioning.drawLine;
                            });
                          },
                          icon: Icon(
                            CupertinoIcons.minus,
                            color: _functioning == Functioning.drawLine
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _functioning =
                                  _functioning == Functioning.drawArrow
                                      ? Functioning.none
                                      : Functioning.drawArrow;
                            });
                          },
                          icon: Icon(
                            Icons.arrow_forward_outlined,
                            color: _functioning == Functioning.drawArrow
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                      IconButton(
                          onPressed: () async {
                            // var image = await boardKey.currentState?.rendered;
                            // if (image != null) {
                            //   if (kIsWeb) {
                            //     await WebImageDownloader().downloadImageFromUInt8List(
                            //       uInt8List:
                            //           (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List(),
                            //       name: "export",
                            //       imageQuality: 1,
                            //     );
                            //   }
                            // }
                          },
                          icon: const Icon(
                            Icons.download,
                            color: Colors.grey,
                          )),
                    ],
                  ),
                  Expanded(
                    child: Board(
                      key: boardKey,
                      isHanding: _functioning == Functioning.handing,
                      mouseDownHandle: (location, defaultHandle) {
                        if (_functioning == Functioning.none) {
                          defaultHandle.call();
                        } else {
                          for (var element in _children) {
                            element.deSelected();
                          }
                          AbstractShape? element;

                          switch (_functioning) {
                            case Functioning.drawRect:
                              element = TextBoxShape(
                                color: Colors.transparent,
                                location: location.translate(-1, -1),
                                size: const Size(1, 1),
                                borderColor: Colors.black,
                              );
                              break;
                            case Functioning.drawCircle:
                              element = CircleShape(
                                color: Colors.transparent,
                                location: location.translate(-1, -1),
                                size: const Size(1, 1),
                                borderColor: Colors.black,
                              );
                              break;
                            case Functioning.drawChatBubble:
                              element = ChatBubbleShape(
                                color: Colors.transparent,
                                location: location.translate(-1, -1),
                                size: const Size(1, 1),
                                borderColor: Colors.black,
                              );
                              break;
                            case Functioning.drawArrow:
                              element = ArrowShape(
                                color: Colors.black,
                                location: location.translate(-1, -1),
                                length: 1,
                              );
                              break;
                            case Functioning.drawLine:
                              element = LineShape(
                                color: Colors.black,
                                location: location.translate(-1, -1),
                                length: 1,
                              );
                              break;
                            case Functioning.handing:
                              break;
                            case Functioning.none:
                              break;
                          }
                          if (element != null) {
                            setState(() {
                              _children.add(element!);
                              element.selected();
                              element.startResize(
                                  element.overResizePoint(location)!);
                              _selectedShape = element;
                              _showEditTab = true;
                            });
                          }
                        }
                      },
                      onMouseUpComplete: () {
                        if (_functioning != Functioning.none) {
                          setState(() {
                            _functioning = Functioning.none;
                          });
                        }
                      },
                      size: const Size(1820, 1280),
                      children: _children,
                      onRemoveShape: (shape) {
                        setState(() {
                          _children = List.from(_children)..remove(shape);
                        });
                      },
                      onMouseLocationChange: (location) {
                        _mouseLocation.sink.add(location);
                      },
                      onShapeSelected: (shape) {
                        if (shape == null) {
                          if (_showEditTab) {
                            setState(() {
                              _showEditTab = false;
                            });
                          }
                        } else {
                          setState(() {
                            _selectedShape = shape;
                            _showEditTab = true;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<Offset>(
                stream: _mouseLocation.stream,
                builder: (context, snapshot) {
                  return Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration:
                          BoxDecoration(color: Colors.blueGrey.withOpacity(.1)),
                      child: Center(
                          child: Text(
                              '${snapshot.data?.dx.toInt()} x ${snapshot.data?.dy.toInt()}')),
                    ),
                  );
                })
          ],
        )),
        AnimatedSize(
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: _showEditTab ? 250 : 0,
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Column(
              children: [
                if (_selectedShape != null) ...[
                  if (_selectedShape is TextBoxShape)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(
                            text: (_selectedShape as TextBoxShape).text),
                        onSubmitted: (value) {
                          setState(() {
                            (_selectedShape as TextBoxShape).text = value;
                          });
                        },
                        decoration: const InputDecoration(
                            prefixIcon: Text('V'),
                            border: OutlineInputBorder()),
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: TextEditingController(
                              text: '${_selectedShape!.location.dx.toInt()}'),
                          onSubmitted: (value) {
                            _selectedShape!.location = Offset(
                                double.parse(value),
                                _selectedShape!.location.dy);
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Text('X'),
                              border: OutlineInputBorder()),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: TextEditingController(
                              text: '${_selectedShape!.location.dy.toInt()}'),
                          onSubmitted: (value) {
                            _selectedShape!.location = Offset(
                                _selectedShape!.location.dx,
                                double.parse(value));
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Text('Y'),
                              border: OutlineInputBorder()),
                        ),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: TextEditingController(
                              text: '${_selectedShape!.size.width.toInt()}'),
                          onSubmitted: (value) {
                            _selectedShape!.size = Size(double.parse(value),
                                _selectedShape!.size.height);
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Text('W'),
                              border: OutlineInputBorder()),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: TextEditingController(
                              text: '${_selectedShape!.size.height.toInt()}'),
                          onSubmitted: (value) {
                            _selectedShape!.size = Size(
                                _selectedShape!.size.width,
                                double.parse(value));
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Text('H'),
                              border: OutlineInputBorder()),
                        ),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Color'),
                      MaterialButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  availableColors: _defaultColors,
                                  pickerColor: _selectedShape!.color,
                                  onColorChanged: (value) {
                                    setState(() {
                                      _selectedShape!.color = value;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        height: 50,
                        minWidth: 150,
                        color: _selectedShape!.color,
                      )
                    ],
                  ),
                  if (_selectedShape is RectangleShape) ...[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Border Color'),
                        MaterialButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: SingleChildScrollView(
                                  child: BlockPicker(
                                    availableColors: _defaultColors,
                                    pickerColor:
                                        (_selectedShape as RectangleShape)
                                                .borderColor ??
                                            Colors.transparent,
                                    onColorChanged: (value) {
                                      setState(() {
                                        (_selectedShape as RectangleShape)
                                            .borderColor = value;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          height: 50,
                          minWidth: 150,
                          color: (_selectedShape as RectangleShape).borderColor,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: TextEditingController(
                            text:
                                '${(_selectedShape as RectangleShape).borderRadius.x.round()}'),
                        onSubmitted: (value) {
                          setState(() {
                            (_selectedShape as RectangleShape).borderRadius =
                                Radius.circular(double.parse(value));
                          });
                        },
                        decoration: const InputDecoration(
                            prefixIcon: Text('Border'),
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                  if (_selectedShape is TextBoxShape) ...[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Text Color'),
                        MaterialButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: SingleChildScrollView(
                                  child: BlockPicker(
                                    availableColors: _defaultColors,
                                    pickerColor:
                                        (_selectedShape as TextBoxShape)
                                                .textStyle
                                                .color ??
                                            Colors.transparent,
                                    onColorChanged: (value) {
                                      setState(() {
                                        (_selectedShape as TextBoxShape)
                                                .textStyle =
                                            (_selectedShape as TextBoxShape)
                                                .textStyle
                                                .copyWith(
                                                  color: value,
                                                );
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          height: 50,
                          minWidth: 150,
                          color:
                              (_selectedShape as TextBoxShape).textStyle.color,
                        )
                      ],
                    ),
                  ]
                ]
              ],
            ),
          ),
        )
      ],
    );
  }
}

const List<Color> _defaultColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
  Colors.white,
  Colors.transparent,
];
