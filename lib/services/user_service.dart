import 'package:flutter/material.dart';
import 'package:todo/database/todo_database.dart';
import 'package:todo/models/user.dart';

class UserService with ChangeNotifier {
  late User
      _currentUser; // we'll use this for the user that is logged in(with specific username)
  bool _busyCreate = false;
  bool _userExist = false;

  User get currentUser => _currentUser;

  bool get busyCreate => _busyCreate;

  bool get userExist => _userExist;

  set userExist(bool value) {
    _userExist = value;
    notifyListeners();
  }

  Future<String> getUser(String username) async {
    String result = 'OK';
    try {
      _currentUser = await TodoDatabase.instance.getUser(username);
      notifyListeners();
    } catch (e) {
      result = getHumanReadableError(e.toString());
    }
    return result;
  }

  Future<String> checkIfUserExist(String username) async {
    String result = 'OK';
    try {
      await TodoDatabase.instance.getUser(username);
    } catch (e) {
      // this is sending same type of data as previous function but we're using it
      // for different things
      result = getHumanReadableError(e.toString());
    }
    return result;
  }

  Future<String> updateCurrentUser(String name) async {
    String result = 'OK';
    _currentUser.name = name; // this update user only in app memory
    // we have to do it also in database and update listeners
    try {
      TodoDatabase.instance.updateUser(_currentUser);
      notifyListeners();
    } catch (e) {
      result = getHumanReadableError(e.toString());
    }
    return result;
  }

  Future<String> createUser(User user) async {
    String result = 'OK';
    _busyCreate = true;
    notifyListeners();
    try {
      await TodoDatabase.instance.createUser(user);
      await Future.delayed(Duration(seconds: 3));
    } catch (e) {
      result = getHumanReadableError(e.toString());
    }
    _busyCreate = false;
    notifyListeners();
    return result;
  }
}

String getHumanReadableError(String message) {
  if (message.contains('UNIQUE constraint failed')) {
    return 'This user already exists in the database. Please choose a new one.';
  }
  if (message.contains('not found in the database')) {
    return 'The user does not exist in the database. Please register first.';
  }
  return message;
}
