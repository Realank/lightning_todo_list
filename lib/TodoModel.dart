import 'dart:core';

class TodoItem {
  String content;
  bool active;
  DateTime createTime;
  DateTime scheduleTime;
  TodoItem({this.content, this.scheduleTime, this.active = true}) : createTime = DateTime.now();
}

List<TodoItem> todoLists = [
  TodoItem(content: '回家做饭', scheduleTime: DateTime(2018, 5, 6)),
  TodoItem(content: '买东西1'),
  TodoItem(content: '买东西2'),
  TodoItem(content: '买东西3'),
  TodoItem(content: '买东西4'),
  TodoItem(content: '买东西5'),
  TodoItem(content: '吃饭6', active: false, scheduleTime: DateTime(2018, 5, 9)),
  TodoItem(content: '买东西7'),
  TodoItem(content: '吃饭8', active: false, scheduleTime: DateTime(2018, 5, 9)),
  TodoItem(content: '买东西9'),
  TodoItem(content: '吃饭00', active: false, scheduleTime: DateTime(2018, 5, 9)),
  TodoItem(content: '买东西000'),
  TodoItem(content: '吃饭00000', active: false, scheduleTime: DateTime(2018, 5, 9)),
];
