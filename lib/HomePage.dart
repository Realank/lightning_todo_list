import 'package:flutter/material.dart';
import 'TodoModel.dart';
import 'package:date_format/date_format.dart';
import 'package:dragable_flutter_list/dragable_flutter_list.dart';
import 'DragView.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

String timeString(DateTime date) {
  final locale = 'zh';
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    //today
    return formatDate(date, ['今天 ', HH, ':', nn]);
  } else if (date.year == now.year) {
    return formatDate(date, [mm, '月', dd, '日 ', HH, ':', nn]);
  } else {
    return formatDate(date, [yyyy, '年', mm, '月', dd, '日 ', HH, ':', nn]);
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inputting;
  final scrollController = ScrollController();
  final TodoProvider todoProvider = TodoProvider();
  List<TodoItem> list = [];
  @override
  void initState() {
    super.initState();
    inputting = false;
    todoProvider.open('todo.db').then((result) {
      reloadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    todoProvider.close();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void reloadData() {
    todoProvider.getAll().then((List<TodoItem> list) {
      list.sort((final item1, final item2) => item2.order - item1.order);
      this.list = list;
      setState(() {});
    });
  }

  void _showDatePicker(context, index) {
    if (inputting) {
      setState(() {
        inputting = false;
      });
    }
    final item = list[index];
    final currentTime = item.scheduleTime != null ? item.scheduleTime : DateTime.now();
    DatePicker.showDateTimePicker(
      context,
      locale: 'zh',
      currentTime: currentTime,
      showTitleActions: true,
//      locale: 'zh',
      onChanged: (time) {
        print('onChanged date: $time');
      },
      onConfirm: (time) {
        setState(() {
          item.scheduleTime = time;
          todoProvider.update(item);
          setState(() {});
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
          print('submit');
          if (text.length > 0) {
            final item = TodoItem(content: text, order: list.length);
            todoProvider.insert(item).then((index) {
              inputting = false;
              _scrollListToTop();
              reloadData();
            });
          } else {
            inputting = false;
            _scrollListToTop();
            setState(() {});
          }
        },
        autofocus: true,
        decoration: InputDecoration.collapsed(hintText: '请输入内容...'),
        style: TextStyle(fontSize: 22.0, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildCell(context, index, containInput) {
    print('build cell $index');
    if (index >= list.length) {
      return null;
    }
    TodoItem item = list[index];
    final textStyle = item.active
        ? null
        : TextStyle(
            decorationStyle: TextDecorationStyle.solid, decoration: TextDecoration.lineThrough);

    final trailing = <Widget>[];
    if (item.scheduleTime != null) {
      trailing.add(
        Text(timeString(item.scheduleTime), style: textStyle),
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

//    trailing.add(Text('order:${item.order}'));

    return DragView(
      onPanGes: (isLeft) {
        print('left $isLeft');
        if (isLeft) {
          item.active = true;
          todoProvider.update(item);
          setState(() {});
        } else {
          if (item.active) {
            item.active = false;
            todoProvider.update(item);
            setState(() {});
          } else {
            todoProvider.delete(item.id).then((result) {
              reloadData();
            });
          }
        }
      },
      child: Card(
        color: item.active ? Colors.white : Colors.grey.shade300,
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
      list.length,
      scrollController: scrollController,
      itemBuilder: (context, index) => _buildCell(context, index, inputting),
      onDragFinish: (before, after) {
        print('on drag finish $before $after');
        var data = list[before];
        list.removeAt(before);
        list.insert(after, data);
        todoProvider.changeOrder(list).then((result) {
          reloadData();
        });
      },
      canDrag: (index) => true,
      canBeDraggedTo: (from, to) => to < 5,
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
        title: Text('待办事项'),
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
