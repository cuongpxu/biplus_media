
import 'package:authentication_repository/authentication_repository.dart';
import 'package:biplus_media/src/pages/auth/reset_account/cubit/reset_password_state.dart';
import 'package:bloc/bloc.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

class ResetAccountCubit extends Cubit<ResetAccountState> {

  ResetAccountCubit(this._authenticationRepository) : super(const ResetAccountState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([
        email
      ]),
    ));
  }

  Future<void> resetFormSubmitted() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.resetPassword(
        email: state.email.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
//    } on SignUpWithEmailAndPasswordFailure catch (e) {
//      emit(state.copyWith(
//        errorMessage: e.message,
//        status: FormzStatus.submissionFailure,
//      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}