import 'package:authentication_repository/authentication_repository.dart';
import 'package:biplus_media/src/app/bloc/app_bloc.dart';
import 'package:biplus_media/src/widgets/otpinput_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../sign_up.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.status.isSubmissionSuccess) {
          showOtpInputDialog(
            context: context,
            title: 'Nhập OTP',
            message:
                'Vui lòng kiểm tra email của bạn và nhập mã OTP nhận được vào ô bên dưới!',
            initialText: '',
            keyboardType: TextInputType.text,
            onSubmitted: (value) {
              Navigator.pop(context);
              context.read<SignUpCubit>().otpSubmitted(value);
            },
          );
        } else if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content: Text(
                state.errorMessage ?? 'Sign Up Failure',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              )),
            );
        }else if (state.otpStatus.isSubmissionSuccess) {
          context.read<SignUpCubit>().signUp();
        }else if (state.signUpStatus.isSubmissionSuccess) {
          User? user = context.read<SignUpCubit>().state.userInfo?.user;
          if (user != null){
            context.read<AppBloc>().add(AppUserChanged(user));
            Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
          }
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EmailInput(),
            const SizedBox(height: 8),
            const _PasswordInput(),
            const SizedBox(height: 8),
            const _ConfirmPasswordInput(),
            const SizedBox(height: 8),
            _SignUpButton(),
          ],
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: TextField(
            key: const Key('signUpForm_emailInput_textField'),
            onChanged: (email) => context.read<SignUpCubit>().emailChanged(email),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              helperText: '',
              errorText: state.email.invalid ? 'invalid email' : null,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
          )
        );
      },
    );
  }
}


class _PasswordInput extends StatefulWidget {
  const _PasswordInput({Key? key}) : super(key: key);

  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: TextFormField(
              key: const Key('signUpForm_passwordInput_textField'),
              onChanged: (password) =>
                  context.read<SignUpCubit>().passwordChanged(password),
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: '',
                errorText: state.password.invalid ? 'Invalid password' : null,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorStyle: const TextStyle(color: Colors.red),
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            )
        );
      },
    );
  }
}


class _ConfirmPasswordInput extends StatefulWidget {
  const _ConfirmPasswordInput({Key? key}) : super(key: key);

  @override
  _ConfirmPasswordInputState createState() => _ConfirmPasswordInputState();
}

class _ConfirmPasswordInputState extends State<_ConfirmPasswordInput> {
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
      previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: TextField(
            key: const Key('signUpForm_confirmedPasswordInput_textField'),
            onChanged: (confirmPassword) => context
                .read<SignUpCubit>()
                .confirmedPasswordChanged(confirmPassword),
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: 'Confirm password',
              helperText: '',
              errorText: state.confirmedPassword.invalid
                  ? 'Passwords do not match'
                  : null,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              errorStyle: const TextStyle(color: Colors.red),
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('signUpForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  onSurface: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  primary: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: state.status.isValidated
                    ? () => context.read<SignUpCubit>().signUpFormSubmitted()
                    : null,
                child: const Text('SIGN UP'),
              );
      },
    );
  }
}
