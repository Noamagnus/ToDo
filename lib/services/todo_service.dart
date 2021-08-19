import 'package:flutter/material.dart';
import 'package:todo/database/todo_database.dart';
import 'package:todo/models/todo.dart';

class TodoService with ChangeNotifier {
  List<Todo> _todoes = [];

  List<Todo> get todoes => _todoes;

  Future<String> getTodoes(String username) async {
    try {
      _todoes = await TodoDatabase.instance.getTodos(username);
      notifyListeners();
    } catch (e) {
      return e.toString();
    }
    return 'OK';
  }

  Future<String> deleteTodo(Todo todo) async {
    try {
      await TodoDatabase.instance.deleteTodo(todo);
    } catch (e) {
      return e.toString();
    }
    String result = await getTodoes(// this will notify listeners
        todo.username); // after deleting we're calling to update listview
    return result;
  }

  Future<String> createTodo(Todo todo) async {
    try {
      await TodoDatabase.instance.createTodo(todo);
    } catch (e) {
      return e.toString();
    }
    String result = await getTodoes(// getTodoes will notify listeners
        todo.username); // after adding we're calling to update list view
    return result;
  }

  Future<String> toggle(Todo todo) async {
    try {
      await TodoDatabase.instance.toggleTodoDone(todo);
    } catch (e) {
      return e.toString();
    }
    String result = await getTodoes(// getTodoes will notify listeners
        todo.username); // after adding we're calling to update list view
    return result;
  }
}
