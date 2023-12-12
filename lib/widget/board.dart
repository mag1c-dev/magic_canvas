import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:magic_canvas/shape/shape.dart';
import '../painter/board_painter.dart';
import '../utils/utils.dart';

typedef RemoveShapeCallback = Function(AbstractShape shape);
typedef SelectShapeCallback = Function(AbstractShape? shape);
typedef MouseLocationCallback = Function(Offset location);
typedef MouseDownCallback = Function(
    Offset location, VoidCallback defaultHandle);
typedef MouseUpCompleteCallback = Function();
typedef MouseDownCompleteCallback = Function(Offset location);

class Board extends StatefulWidget {
  const Board({
    super.key,
    this.size,
    this.color,
    this.children,
    this.isHanding = false,
    this.onRemoveShape,
    this.onMouseLocationChange,
    this.mouseDownHandle,
    this.onMouseUpComplete,
    this.onMouseDownComplete,
    this.onShapeSelected,
  });

  final Size? size;
  final Color? color;
  final List<AbstractShape>? children;
  final bool isHanding;
  final RemoveShapeCallback? onRemoveShape;
  final MouseLocationCallback? onMouseLocationChange;
  final MouseDownCallback? mouseDownHandle;
  final MouseDownCompleteCallback? onMouseDownComplete;
  final MouseUpCompleteCallback? onMouseUpComplete;
  final SelectShapeCallback? onShapeSelected;

  @override
  State<Board> createState() => BoardState();
}

class BoardState extends State<Board> {
  final _textEditingController = TextEditingController();
  final _transformationController = TransformationController();
  final _focusNodeEditText = FocusNode();

  var _mouse = Offset.zero;
  TextBoxShape? _editingTextBox;

  @override
  void initState() {
    super.initState();
    _transformationController.value.setEntry(0, 3, 0);
    _transformationController.value.setEntry(1, 3, 0);
  }

  @override
  Widget build(BuildContext context) {
    widget.children?.sort(
      (a, b) => a.zIndex - b.zIndex,
    );
    return Listener(
      onPointerHover: (event) {
        Offset localPosition =
            _transformationController.toScene(event.localPosition);

        widget.onMouseLocationChange?.call(localPosition);
        if (!widget.isHanding) {
          widget.children?.forEach((element) {
            if (element.isOverObject(localPosition.rotate(
                angle: -element.angle, center: element.center))) {
              setState(() {
                element.highlight();
              });
            } else {
              setState(() {
                element.unHighlight();
              });
            }
          });
        }
      },
      onPointerDown: widget.isHanding
          ? null
          : (details) {
              Offset localPosition =
                  _transformationController.toScene(details.localPosition);
              handleMouseDown(localPosition);
            },
      child: InteractiveViewer(
        scaleEnabled: true,
        transformationController: _transformationController,
        panEnabled: widget.isHanding,
        constrained: false,
        minScale: .01,
        child: Stack(
          children: [
            GestureDetector(
              onDoubleTapDown: widget.isHanding
                  ? null
                  : (details) {
                      Offset localPosition = details.localPosition;

                      TextBoxShape? textBox = widget.children
                          ?.where((element) => element.isSelected)
                          .toList()
                          .lastWhereNullable((element) =>
                              element.isOverObject(localPosition) &&
                              element is TextBoxShape) as TextBoxShape?;
                      if (textBox != null) {
                        textBox.startEdit();
                        _textEditingController.text = textBox.text;
                        setState(() {
                          _editingTextBox = textBox;
                        });
                        _focusNodeEditText.requestFocus();
                      }
                    },
              onPanUpdate: widget.isHanding
                  ? null
                  : (details) {
                      handleMouseMove(details.localPosition);
                    },
              onPanEnd: widget.isHanding
                  ? null
                  : (details) {
                      handleMouseUp();
                    },
              child: CustomPaint(
                size: widget.size ?? MediaQuery.of(context).size,
                painter: BoardPainter(
                  background: widget.color ?? Colors.grey,
                  children: widget.children,
                ),
              ),
            ),
            if (_editingTextBox != null)
              Positioned(
                top: _editingTextBox!.location.dy,
                left: _editingTextBox!.location.dx,
                child: Transform.rotate(
                  angle: _editingTextBox!.angle,
                  child: SizedBox(
                    width: _editingTextBox!.size.width,
                    height: _editingTextBox!.size.height,
                    child: Center(
                      child: SizedBox(
                        width: _editingTextBox!.size.width,
                        child: TextField(
                          expands: true,
                          controller: _textEditingController,
                          focusNode: _focusNodeEditText,
                          style: _editingTextBox!.textStyle,
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (value) {
                            setState(() {
                              _editingTextBox?.text =
                                  _textEditingController.text;
                            });
                          },
                          onSubmitted: (value) {
                            setState(() {
                              _editingTextBox?.endEdit();
                              _editingTextBox = null;
                            });
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            isCollapsed: true,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          maxLines: null,
                          textAlign: _editingTextBox!.textAlign,
                        ),
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<ui.Image> get rendered {
    var pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    BoardPainter painter = BoardPainter(children: widget.children, background: widget.color);
    var size = context.size;
    painter.paint(canvas, size!);
    return pictureRecorder.endRecording().toImage(size.width.floor(), size.height.floor());
  }

  void handleMouseDown(Offset localPosition) {
    if (widget.mouseDownHandle != null) {
      widget.mouseDownHandle?.call(
        localPosition,
        () => _defaultMouseDownHandle(localPosition),
      );
    } else {
      _defaultMouseDownHandle(localPosition);
    }
    widget.onMouseDownComplete?.call(localPosition);
    _mouse = localPosition;
  }

  void handleMouseMove(Offset localPosition) {
    widget.children?.where((element) => element.isSelected).forEach((element) {
      if (element.isResizing) {
        setState(() {
          element.resize(_mouse, localPosition);
        });
      } else if (element.isRotating) {
        setState(() {
          element.rotate(_mouse, localPosition);
        });
      } else if (element.isDragging) {
        setState(() {
          element.translate(_mouse, localPosition);
        });
      }
    });
    widget.onMouseLocationChange?.call(localPosition);
    _mouse = localPosition;
  }

  void handleMouseUp() {
    setState(() {
      widget.children?.forEach((element) {
        element.endDrag();
        element.endResize();
        element.endRotate();
      });
      widget.onMouseUpComplete?.call();
    });
  }

  void _defaultMouseDownHandle(Offset localPosition) {
    AbstractShape? element = widget.children?.lastWhereNullable(
      (element) {
        Offset mouseRotated = localPosition.rotate(
          center: element.location.translate(
            element.size.width / 2,
            element.size.height / 2,
          ),
          angle: -element.angle,
        );
        return element.isOverObject(mouseRotated) ||
            element.isOverResizePoint(mouseRotated) ||
            element.isOverRotatePoint(mouseRotated) ||
            element.isOverRemovePoint(mouseRotated);
      },
    );

    if (element != null) {
      if (!element.isSelected) {
        widget.children?.forEach((element) {
          element.deSelected();
        });
      }

      if (element != _editingTextBox) {
        setState(() {
          _editingTextBox?.endEdit();
          _editingTextBox = null;
        });
      }

      Offset mouseRotated = localPosition.rotate(
        center: element.location.translate(
          element.size.width / 2,
          element.size.height / 2,
        ),
        angle: -element.angle,
      );

      if (element.isOverResizePoint(mouseRotated)) {
        setState(() {
          element.selected();
          element.startResize(element.overResizePoint(mouseRotated)!);
        });
      } else if (element.isOverRotatePoint(mouseRotated)) {
        setState(() {
          element.selected();
          element.startRotate(element.overRotatePoint(mouseRotated)!);
        });
      } else if (element.isOverRemovePoint(mouseRotated)) {
        widget.onRemoveShape?.call(element);
      } else if (element.isOverObject(mouseRotated)) {
        setState(() {
          element.selected();
          element.startDrag();
        });
      }
    } else {
      setState(() {
        _editingTextBox?.endEdit();
        _editingTextBox = null;
        widget.children?.forEach((element) {
          element.deSelected();
        });
        widget.onShapeSelected?.call(null);
      });
    }
  }
}
