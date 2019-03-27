import 'package:flutter_form/login/login_event.dart';
import 'package:flutter_form/login/login_state.dart';
import 'package:bloc/bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  @override
  LoginState get initialState => LoginState();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is ChangeNameEvent) {
      if (event.name.length < 3) {
        yield currentState.copyWith(
            name: event.name, nameError: "Name is too short.");
        return;
      }
      yield currentState.copyWith(name: event.name, nameError: null);
      return;
    }
    if (event is ChangeAgreement) {
      yield currentState.copyWith(hasAgreed: event.hasAgreed);
    }
  }
}
