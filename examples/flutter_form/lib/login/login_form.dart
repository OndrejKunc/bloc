import 'package:flutter/material.dart';
import 'package:flutter_form/login/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form/login/login_event.dart';
import 'package:flutter_form/login/login_state.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  LoginBloc loginBloc;

  @override
  void initState() {
    loginBloc = LoginBloc();
    super.initState();
  }

  @override
  void dispose() {
    loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            BlocProjectionBuilder<LoginEvent, LoginState, String>(
              bloc: loginBloc,
              converter: (state) => state.nameError,
              builder: (_, nameError) {
                return TextField(
                  decoration:
                      InputDecoration(labelText: "Name", errorText: nameError),
                  onChanged: (name) =>
                      loginBloc.dispatch(ChangeNameEvent(name)),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: <Widget>[
                  BlocProjectionBuilder<LoginEvent, LoginState, bool>(
                    bloc: loginBloc,
                    converter: (state) => state.hasAgreed,
                    builder: (_, hasAgreed) {
                      return Checkbox(
                        onChanged: (value) =>
                            loginBloc.dispatch(ChangeAgreement(value)),
                        value: hasAgreed,
                      );
                    },
                  ),
                  Text("Agree to license")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: BlocProjectionBuilder<LoginEvent, LoginState, bool>(
                bloc: loginBloc,
                converter: (state) => state.hasAgreed,
                builder: (_, hasAgreed) {
                  return RaisedButton(
                    onPressed: hasAgreed ? _showDialog : null,
                    child: Text("Login"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Done"),
          content: new Text("Login successful"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
