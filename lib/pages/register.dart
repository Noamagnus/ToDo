import 'package:flutter/material.dart';
import 'package:todo/models/user.dart';
import 'package:todo/services/user_service.dart';
import 'package:todo/widgets/app_textfield.dart';
import 'package:todo/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController usernameController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple, Colors.blue],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        'Register User',
                        style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w200,
                            color: Colors.white),
                      ),
                    ),
                    Focus(
                      onFocusChange: (value) async {
                        if (!value) // this means if it looses focus
                        {
                          String result = await context
                              .read<UserService>()
                              .checkIfUserExist(usernameController.text.trim());
                          if (result == 'OK') {
                            context.read<UserService>().userExist = true;
                          } else {
                            context.read<UserService>().userExist = false;
                            if (result.contains(
                                'This user already exists in the database. Please choose a new one.')) {
                              showSnackBar(context, result);
                            }
                          }
                        }
                      },
                      child: AppTextField(
                        controller: usernameController,
                        labelText: 'Please enter your username',
                      ),
                    ),
                    Selector<UserService, bool>(
                      //bool is the type of the value we're
                      //focused on  changing
                      // selector will fire only if userExist change!!
                      selector: (context, value) => value.userExist,
                      builder: (BuildContext context, value, Widget? child) {
                        return value
                            ? Text(
                                'username exists, please choose another',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w800),
                              )
                            : Container();
                      },
                    ),
                    AppTextField(
                      controller: nameController,
                      labelText: 'Please enter your name',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.purple),
                        onPressed: () async {
                          FocusManager.instance.primaryFocus
                              ?.unfocus(); // unfocus keyboard after pressing register
                          if (usernameController.text.isEmpty ||
                              nameController.text.isEmpty) {
                            showSnackBar(context,
                                'Please enter all fields'); //this is our custom snackBar from dialog widget
                          } else {
                            // now we can create user and add it to database
                            // now we're initializing User object
                            User user = User(
                              username: usernameController.text.trim(),
                              name: nameController.text.trim(),
                            );
                            String result = await context
                                .read<UserService>()
                                .createUser(user);
                            if (result != 'OK') {
                              showSnackBar(
                                context,
                                result,
                              );
                            } else {
                              showSnackBar(
                                  context, 'New user created successfully');
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 30,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          Selector<UserService, bool>(
            selector: (context, value) => value.busyCreate,
            builder: (context, value, child) =>
                value ? AppProgressIndicator() : Container(),
          )
        ],
      ),
    );
  }
}

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white.withOpacity(0.5),
      child: Center(
        child: Container(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.purple,
          ),
        ),
      ),
    );
  }
}
