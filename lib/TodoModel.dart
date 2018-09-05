import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'dart:io';

final String tableTodo = "todo";
final String columnId = "id";
final String columnContent = "content";
final String columnActive = "active";
final String columnCreateTime = 'createTime';
final String columnScheduleTime = 'scheduleTime';
final String columnOrder = 'listorder';

class TodoItem {
  int id;
  String content;
  bool active;
  DateTime createTime;
  DateTime scheduleTime;
  int order;
  TodoItem({this.id, this.content, this.scheduleTime, this.active = true, this.order = 0})
      : createTime = DateTime.now();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnContent: content,
      columnActive: active == true ? 1 : 0,
      columnCreateTime: createTime.toString(),
      columnScheduleTime: scheduleTime.toString(),
      columnOrder: order
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  TodoItem.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    content = map[columnContent];
    active = map[columnActive] == 1;
    createTime = DateTime.tryParse(map[columnCreateTime]);
    scheduleTime = DateTime.tryParse(map[columnScheduleTime]);
    order = map[columnOrder];
  }
}

Future<String> initDbPath(String dbName) async {
  var databasePath = await getDatabasesPath();
  // print(databasePath);
  String path = join(databasePath, dbName);

  // make sure the folder exists
  if (await new Directory(dirname(path)).exists()) {
//    await deleteDatabase(path);
  } else {
    try {
      await new Directory(dirname(path)).create(recursive: true);
    } catch (e) {
      print(e);
    }
  }
  return path;
}

class TodoProvider {
  Database db;

  Future open(String path) async {
    String dbPath = await initDbPath(path);
    db = await openDatabase(dbPath, version: 1, onCreate: (Database db, int version) async {
      print('create db');
      await db.execute('''
create table $tableTodo ( 
  $columnId integer primary key autoincrement, 
  $columnContent text not null,
  $columnActive integer not null,
  $columnCreateTime text,
  $columnScheduleTime text,
  $columnOrder integer
  )
''');
    });
  }

  Future<TodoItem> insert(TodoItem todo) async {
    todo.id = await db.insert(tableTodo, todo.toMap());
    return todo;
  }

  Future<TodoItem> getTodo(int id) async {
    List<Map> maps = await db.query(tableTodo,
        columns: [columnId, columnContent, columnActive, columnCreateTime, columnScheduleTime],
        where: "$columnId = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return new TodoItem.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TodoItem>> getAll() async {
    List<Map> maps = await db.query(tableTodo,
        columns: [
          columnId,
          columnContent,
          columnActive,
          columnCreateTime,
          columnScheduleTime,
          columnOrder
        ],
        orderBy: '$columnOrder DESC,$columnScheduleTime DESC,$columnCreateTime DESC');
    List<TodoItem> lists = [];
    for (Map item in maps) {
      lists.add(TodoItem.fromMap(item));
    }
    return lists;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableTodo, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<int> update(TodoItem todo) async {
    return await db.update(tableTodo, todo.toMap(), where: "$columnId = ?", whereArgs: [todo.id]);
  }

  Future changeOrder(List<TodoItem> list) async {
    final length = list.length;
    for (int i = 0; i < length; i++) {
      TodoItem item = list[i];
      if (item.id != null) {
        item.order = length - 1 - i;
        await update(item);
      }
    }
  }

  Future close() async => db.close();
}
