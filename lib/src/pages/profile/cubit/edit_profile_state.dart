

import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

import '../../../models/user_info.dart';

class EditProfileState extends Equatable {
  const EditProfileState({
    this.email = const Email.pure(),
    this.name = const Name.pure(),
    this.phone = const Phone.pure(),
    this.status = FormzStatus.pure,
    this.errorMessage,
    this.userInfo
  });

  final Email email;
  final Name name;
  final Phone phone;
  final FormzStatus status;
  final String? errorMessage;
  final UserInfo? userInfo;

  @override
  List<Object> get props => [email, status];

  EditProfileState copyWith({
    Email? email,
    Name? name,
    Phone? phone,
    FormzStatus? status,
    String? errorMessage,
    UserInfo? userInfo
  }) {
    return EditProfileState(
        email: email ?? this.email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        userInfo: userInfo ?? this.userInfo
    );
  }
}