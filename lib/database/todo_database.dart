import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/models/user.dart';
import 'package:todo/models/todo.dart';
import 'package:path/path.dart';
import 'dart:async';

class TodoDatabase {
  // This is a instance of a Class TodoDatabase
  static final TodoDatabase instance = TodoDatabase._initialize();

  // I think this is _dataBase object we're gonna get from instance
  // and will be using this object through out our code
  static Database? _dataBase;

  //this is named constructor
  TodoDatabase._initialize();

//Here we're creating tables for user and to do model
  Future _createDB(Database db, int version) async {
    print('createDB fired');
    final userUsernameType = 'TEXT PRIMARY KEY NOT NULL'; //these are types
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';

    //This line of code creates user table
    await db.execute('''CREATE TABLE $userTable (
    ${UserFields.username} $userUsernameType,
    ${UserFields.name} $textType )''');
// This line of code creates to do Table
    await db.execute('''CREATE TABLE $todoTable (
    ${TodoFields.username} $textType,
    ${TodoFields.title} $textType,
    ${TodoFields.done} $boolType,
    ${TodoFields.created} $textType,
    FOREIGN KEY(${TodoFields.username}) REFERENCES $userTable (${UserFields.username})
    )''');
  }

// We need this function to
  Future _onConfigure(Database db) async {
    print('onConfigure fired');
    await db.execute('PRAGMA foreign_keys = ON');
  }

// Finally we're opening database
  Future<Database> _initDB(String fileName) async {
    final dataBasePath = await getDatabasesPath();
    final path = join(dataBasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB, //This is pointer or reference to _createDB function
      onConfigure: _onConfigure,
    );
  }

  // We're adding future for closing database
  Future close() async {
    final db = await instance.database;
    db!.close();
  }

  Future<Database?> get database async {
    // if _dataBase is null our database was not initialized
    if (_dataBase != null) {
      return _dataBase;
    }
    // if its not null we need to initialize it
    else {
      _dataBase = await _initDB('todo.db');
      return _dataBase;
    }
  }

  //Now we cans start with create,read,update and delete

//First we're creating (inserting) user
  Future<User> createUser(User user) async {
    final db = await instance.database;
    // we now checked that db is not gonna be null and we can put ! (exclamation mark) because
    // we already tested it in get database getter
    // insert accept user and values. User we prepared earlier
    await db!.insert(userTable, user.toJson());
    return user;
  }

  //Now we're reading from database

  Future<User> getUser(String username) async {
    final db = await instance.database;
// now we're querying database
    // when we querying database we'll get list of maps
    final maps = await db!.query(
      userTable,
      // we specified columns in allFields in User model
      columns: UserFields.allFields,
      // we can write this way but we don't wanna let someone injecting direct to SQL database
      // where: '${UserFields.username} = $username',
      where: '${UserFields.username} = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first); //because userName is unique
    } else {
      throw Exception('$username not found');
    }
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final result = await db!.query(
      userTable,
      orderBy:
          '${UserFields.username} ASC', //This means that this is ordered by ascending
    );
    return result.map((e) => User.fromJson(e)).toList();
  }

// We're not returning it but only getting a value back of an int
  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return db!.update(
      userTable,
      user.toJson(),
      where: '${UserFields.username} = ?',
      whereArgs: [user.username],
    );
  }

  Future<int> deleteUser(String username) async {
    final db = await instance.database;
    return db!.delete(
      userTable,
      where: '${UserFields.username} = ?',
      whereArgs: [username],
    );
  }

  //Now we're doing functions for "to do" model
  //First we need to add 'to do' to a database

  Future<Todo> createTodo(Todo todo) async {
    final db = await instance.database;
    await db!.insert(todoTable, todo.toJson());
    return todo;
  }

  Future<int> toggleTodoDone(Todo todo) async {
    final db = await instance.database;
    todo.done = !todo.done;
    return db!.update(todoTable, todo.toJson(),
        where: '${TodoFields.title} = ? AND ${TodoFields.username} = ?',
        //we're doing this to be sure that want be SQL injection
        whereArgs: [todo.title, todo.username]);
  }

  //Getting all 'to do's
  Future<List<Todo>> getTodos(String username) async {
    //passing username because its to do list for specific user
    final db = await instance.database;
    final result = await db!.query(
      todoTable,
      where: '${TodoFields.username} = ?',
      whereArgs: [username],
      orderBy:
          '${TodoFields.created} DESC', //This means that this is ordered by descending
    );
    return result.map((e) => Todo.fromJson(e)).toList();
  }

  Future<int> deleteTodo(Todo todo) async {
    final db = await instance.database;
    return db!.delete(
      todoTable,
      where: '${TodoFields.title} = ? AND ${TodoFields.username} = ?',
      whereArgs: [todo.title, todo.username],
    );
  }
}
