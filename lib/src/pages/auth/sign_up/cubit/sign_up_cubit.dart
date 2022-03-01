import 'package:authentication_repository/authentication_repository.dart';
import 'package:biplus_media/src/models/user_info.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:hive/hive.dart';

import '../../../../api/biplus_media_api.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authenticationRepository) : super(const SignUpState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([
        email,
        state.password,
        state.confirmedPassword,
      ]),
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    final confirmedPassword = ConfirmedPassword.dirty(
      password: password.value,
      value: state.confirmedPassword.value,
    );
    emit(state.copyWith(
      password: password,
      confirmedPassword: confirmedPassword,
      status: Formz.validate([
        state.email,
        password,
        confirmedPassword,
      ]),
    ));
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
      password: state.password.value,
      value: value,
    );
    emit(state.copyWith(
      confirmedPassword: confirmedPassword,
      status: Formz.validate([
        state.email,
        state.password,
        confirmedPassword,
      ]),
    ));
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      // await _authenticationRepository.signUp(
      //   email: state.email.value,
      //   password: state.password.value,
      // );

      Map<String, dynamic>? response =
          await BiplusMediaAPI().checkEmail(state.email.value);
      if (response != null) {
        if (response['data'] == 1) {
          emit(state.copyWith(status: FormzStatus.submissionSuccess));
        } else {
          emit(state.copyWith(
            errorMessage: response['message'],
            status: FormzStatus.submissionFailure,
          ));
        }
      } else {
        emit(state.copyWith(
          errorMessage: 'Có lỗi xảy ra, vui lòng thử lại',
          status: FormzStatus.submissionFailure,
        ));
      }
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> otpSubmitted(String otp) async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress,
    otpStatus: FormzStatus.pure,
    signUpStatus: FormzStatus.pure));
    try {
      Map<String, dynamic>? response = await BiplusMediaAPI()
          .checkOtp(state.email.value, OTPType.verifyUser, otp);
      if (response != null) {
        if (response['data'] == 1) {
          emit(state.copyWith(
              otpStatus: FormzStatus.submissionSuccess,
              status: FormzStatus.pure));
        } else {
          emit(state.copyWith(
            errorMessage: response['message'],
            status: FormzStatus.submissionFailure,
          ));
        }
      } else {
        emit(state.copyWith(
          errorMessage: 'Có lỗi xảy ra, vui lòng thử lại',
          status: FormzStatus.submissionFailure,
        ));
      }
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> signUp() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress,
        otpStatus: FormzStatus.pure,
        signUpStatus: FormzStatus.pure));
    try {
      UserInfo? userInfo = await BiplusMediaAPI()
          .signUp(state.email.value, state.password.value);
      if (userInfo != null) {
        await Hive.box('settings').put('user', userInfo);
        emit(state.copyWith(
            signUpStatus: FormzStatus.submissionSuccess,
            status: FormzStatus.pure,
            otpStatus: FormzStatus.pure,
            userInfo: userInfo));
      } else {
        emit(state.copyWith(
          errorMessage: 'Có lỗi xảy ra, vui lòng thử lại',
          status: FormzStatus.submissionFailure,
        ));
      }
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
