import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

typedef void OnPanGesCallBack(bool left);

class DragView extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final OnPanGesCallBack onPanGes;
  DragView({Key key, this.child, this.onPanGes, this.isActive}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Slidable(
      showAllActionsThreshold: 1,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.4,
      child: child,
      actions: <Widget>[
        isActive
            ? IconSlideAction(
                caption: 'Done',
                color: Colors.indigo,
                icon: Icons.done,
                onTap: () {
                  onPanGes(true);
                },
              )
            : IconSlideAction(
                caption: 'On going',
                color: Colors.indigo,
                icon: Icons.directions_run,
                onTap: () {
                  onPanGes(true);
                }),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              onPanGes(false);
            }),
      ],
    );
  }
}

//class DragView extends StatelessWidget {
//  final Widget child;
//  final OnPanGes onPanGes;
//  DragView({Key key, this.child, this.onPanGes}) : super(key: key);
//  @override
//  Widget build(BuildContext context) {
//    double start = -1.0;
//    double end = -1.0;
//    return GestureDetector(
//      onHorizontalDragStart: (detail) {
//        start = detail.globalPosition.dx;
//      },
//      onHorizontalDragUpdate: (detail) {
//        end = detail.globalPosition.dx;
//      },
//      onHorizontalDragEnd: (detail) {
//        if (start - end > 50.0) {
//          //right
//          if (onPanGes != null) {
//            onPanGes(false);
//          }
//        } else if (end - start > 50.0) {
//          //left
//          if (onPanGes != null) {
//            onPanGes(true);
//          }
//        }
//      },
//      child: child,
//    );
//  }
//}
