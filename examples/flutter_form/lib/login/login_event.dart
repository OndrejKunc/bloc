abstract class LoginEvent {}

class ChangeNameEvent extends LoginEvent {
  final String name;

  ChangeNameEvent(this.name);
}

class ChangeAgreement extends LoginEvent {
  final bool hasAgreed;

  ChangeAgreement(this.hasAgreed);
}
