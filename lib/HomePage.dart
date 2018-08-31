import 'package:flutter/material.dart';
import 'TodoModel.dart';
import 'package:date_format/date_format.dart';
import 'package:dragable_flutter_list/dragable_flutter_list.dart';
import 'DragView.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inputting;
  final scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inputting = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void _showDatePicker(context, index) {
    if (inputting) {
      setState(() {
        inputting = false;
      });
    }
    final item = todoLists[index];
    final currentTime = item.scheduleTime != null ? item.scheduleTime : DateTime.now();
    DatePicker.showDateTimePicker(
      context,
      currentTime: currentTime,
      showTitleActions: true,
//      locale: 'zh',
      onChanged: (time) {
        print('onChanged date: $time');
      },
      onConfirm: (time) {
        setState(() {
          item.scheduleTime = time;
        });
      },
    );
  }

  Widget _buildTextField() {
    return Container(
      key: GlobalKey(),
      padding: EdgeInsets.all(10.0) + EdgeInsets.only(top: 10.0),
      child: TextField(
        onSubmitted: (text) {
          if (text.length > 0) {
            final item = TodoItem(content: text);
            todoLists.insert(0, item);
          }
          inputting = false;
          _scrollListToTop();
          setState(() {});
        },
        autofocus: true,
        decoration: InputDecoration.collapsed(hintText: 'Input...'),
        style: TextStyle(fontSize: 22.0, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildCell(context, index, containInput) {
    print('build cell $index');
    if (index >= todoLists.length) {
      return null;
    }
    TodoItem item = todoLists[index];
    final textStyle = item.active
        ? null
        : TextStyle(
            decorationStyle: TextDecorationStyle.solid, decoration: TextDecoration.lineThrough);

    final trailing = <Widget>[];
    if (item.scheduleTime != null) {
      trailing.add(
        Text(formatDate(item.scheduleTime, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]),
            style: textStyle),
      );
    }
    if (item.active) {
      trailing.add(Container(
        padding: EdgeInsets.only(left: 10.0),
//                color: Colors.red,
        child: InkWell(
          onTap: () {
            _showDatePicker(context, index);
          },
          child: Icon(
            Icons.timer,
            size: 20.0,
          ),
        ),
      ));
    }

    return DragView(
      onPanGes: (isLeft) {
        print('left $isLeft');
        if (isLeft) {
          item.active = true;
          setState(() {});
        } else {
          item.active = false;
          setState(() {});
        }
      },
      child: Card(
        color: item.active ? Colors.white : Colors.red.shade100,
        child: ListTile(
          title: Text(item.content, style: textStyle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: trailing,
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return DragAndDropList(
      todoLists.length,
      scrollController: scrollController,
      itemBuilder: (context, index) => _buildCell(context, index, inputting),
      onDragFinish: (before, after) {
        print('on drag finish $before $after');
        var data = todoLists[before];
        todoLists.removeAt(before);
        todoLists.insert(after, data);
      },
      canDrag: (index) => true,
      canBeDraggedTo: (from, to) => false,
      dragElevation: 5.0,
    );
  }

  void _scrollListToTop() {
    if (scrollController.offset > 0) {
      print('scroll');
      scrollController.animateTo(0.0,
          duration: Duration(microseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (inputting) {
      widgets.add(_buildTextField());
    }
    widgets.add(Expanded(child: _buildList()));

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            inputting = !inputting;
            if (inputting) {
              _scrollListToTop();
            }
          });
        },
        child: Icon(inputting ? Icons.keyboard_arrow_down : Icons.add),
      ),
      body: Column(
        children: widgets,
      ),
    );
  }
}
