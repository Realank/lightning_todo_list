import 'package:flutter/material.dart';

typedef void OnPanGes(bool left);

class DragView extends StatelessWidget {
  final Widget child;
  final OnPanGes onPanGes;
  DragView({Key key, this.child, this.onPanGes}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double start = -1.0;
    double end = -1.0;
    return GestureDetector(
      onHorizontalDragStart: (detail) {
        start = detail.globalPosition.dx;
      },
      onHorizontalDragUpdate: (detail) {
        end = detail.globalPosition.dx;
      },
      onHorizontalDragEnd: (detail) {
        if (start - end > 50.0) {
          //right
          if (onPanGes != null) {
            onPanGes(false);
          }
        } else if (end - start > 50.0) {
          //left
          if (onPanGes != null) {
            onPanGes(true);
          }
        }
      },
      child: child,
    );
  }
}
