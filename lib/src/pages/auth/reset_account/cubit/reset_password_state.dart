
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

class ResetAccountState extends Equatable {

  const ResetAccountState ({
    this.email = const Email.pure(),
    this.status = FormzStatus.pure,
    this.errorMessage,
});

  final Email email;
  final FormzStatus status;
  final String? errorMessage;

  @override
  List<Object> get props => [email, status];

  ResetAccountState copyWith({
    Email? email,
    FormzStatus? status,
    String? errorMessage,
  }) {
    return ResetAccountState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}