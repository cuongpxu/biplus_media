import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

import 'edit_profile_state.dart';


class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._authenticationRepository) : super(const EditProfileState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email]),
    ));
  }

  void nameChanged(String value) {
    final name = Name.dirty(value);
    emit(state.copyWith(
      name: name,
      status: Formz.validate([name]),
    ));
  }

  void phoneChanged(String value) {
    final phone = Phone.dirty(value);
    emit(state.copyWith(
      phone: phone,
      status: Formz.validate([phone]),
    ));
  }
}