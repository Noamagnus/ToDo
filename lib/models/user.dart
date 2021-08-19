final String userTable = 'user';

// This is user field in a database
class UserFields {
  static final String username = 'username';
  static final String name = 'name';
  static final List<String> allFields = [username, name];
}

class User {
  final String username;
  String name;

  User({
    required this.username,
    required this.name,
  });

  //next line of code converts user object to a map
  Map<String, Object?> toJson() => {
        // 'username': username,
        // 'name': name,
        //the  reason why we have UserFields is to use it like this
        UserFields.username: username,
        UserFields.name: name,
      };

  //next line of code is for fetching data from SQL and convert it to
// user Object

  static User fromJson(Map<String, Object?> sql) {
    return User(
      name: sql[UserFields.name] as String,
      username: sql[UserFields.username] as String,
    );
  }
}
