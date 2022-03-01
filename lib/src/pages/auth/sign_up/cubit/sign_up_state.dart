part of 'sign_up_cubit.dart';

enum ConfirmPasswordValidationError { invalid }

class LoginType {
  static const email = 0;
  static const facebook = 1;
  static const google = 2;
}

class OTPType {
  static const verifyUser = 1;
  static const forgotPass = 2;

}

class SignUpState extends Equatable {
  const SignUpState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.status = FormzStatus.pure,
    this.otpStatus = FormzStatus.pure,
    this.signUpStatus = FormzStatus.pure,
    this.errorMessage,
    this.userInfo
  });

  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FormzStatus status;
  final FormzStatus otpStatus;
  final FormzStatus signUpStatus;
  final String? errorMessage;
  final UserInfo? userInfo;

  @override
  List<Object> get props => [email, password, confirmedPassword, status];

  SignUpState copyWith({
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FormzStatus? status,
    FormzStatus? otpStatus,
    FormzStatus? signUpStatus,
    String? errorMessage,
    UserInfo? userInfo,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      status: status ?? this.status,
      otpStatus: otpStatus ?? this.otpStatus,
      signUpStatus: signUpStatus ?? this.signUpStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      userInfo: userInfo ?? this.userInfo
    );
  }
}