class LoginState {
  final String name;
  final String nameError;
  final bool hasAgreed;

  LoginState({this.name = "", this.nameError, this.hasAgreed = false});

  LoginState copyWith({String name, String nameError, bool hasAgreed}) {
    return LoginState(
        name: name ?? this.name,
        nameError: nameError,
        hasAgreed: hasAgreed ?? this.hasAgreed);
  }
}
