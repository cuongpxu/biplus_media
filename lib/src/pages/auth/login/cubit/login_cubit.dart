import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:hive/hive.dart';

import '../../../../api/biplus_media_api.dart';
import '../../../../models/user_info.dart';
import '../../sign_up/cubit/sign_up_cubit.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password]),
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password]),
    ));
  }

  Future<void> logInWithCredentials() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      UserInfo? userInfo = await BiplusMediaAPI().signIn(loginType: LoginType.email,
          email: state.email.value, password: state.password.value);
      if (userInfo != null){
        await Hive.box('settings').put('user', userInfo);
        emit(state.copyWith(status: FormzStatus.submissionSuccess, userInfo: userInfo));
      }else{
        emit(state.copyWith(
          errorMessage: 'Có lỗi xảy ra, vui lòng thử lại',
          status: FormzStatus.submissionFailure,
        ));
      }
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } on Exception catch (e) {
      print(e);
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      final googleUserInfo = await _authenticationRepository.logInWithGoogle();
      print(googleUserInfo);
      UserInfo? userInfo = await BiplusMediaAPI().signIn(loginType: LoginType.google,
          email: googleUserInfo['email'], fullName: googleUserInfo['name'],
          socialId: googleUserInfo['uid'], avatar: googleUserInfo['avatar']
      );
      if (userInfo != null){
        await Hive.box('settings').put('user', userInfo);
        emit(state.copyWith(status: FormzStatus.submissionSuccess, userInfo: userInfo));
      }else{
        emit(state.copyWith(
          errorMessage: 'Có lỗi xảy ra, vui lòng thử lại',
          status: FormzStatus.submissionFailure,
        ));
      }
    } on LogInWithGoogleFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> logInWithFacebook() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.logInWithFacebook();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}