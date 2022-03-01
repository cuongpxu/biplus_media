import 'package:authentication_repository/authentication_repository.dart';
import 'package:biplus_media/src/app/bloc/app_bloc.dart';
import 'package:biplus_media/src/pages/auth/reset_account/view/reset_account_page.dart';
import 'package:biplus_media/src/pages/auth/sign_up/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';

import '../login.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failure',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                    ),),
              ),
            );
        }else if (state.status.isSubmissionSuccess) {
          User? user = context.read<LoginCubit>().state.userInfo?.user;
          if (user != null){
            context.read<AppBloc>().add(AppUserChanged(user));
            Navigator.pop(context);
          }
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              _EmailInput(),
              const SizedBox(height: 5),
              const _PasswordInput(),
              const SizedBox(height: 8),
              _LoginButton(),
              const SizedBox(height: 8),
              Column(
                children: [
                  _GoogleLoginButton(),
                  const SizedBox(height: 8),
                  _FacebookLoginButton()
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SignUpButton(),
                  const SizedBox(width: 5),
                  _ForgetButton()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: TextField(
            key: const Key('loginForm_emailInput_textField'),
            onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              //  labelStyle: TextStyle(color: Colors.white),
              labelText: 'Email',
              helperText: '',
              errorText: state.email.invalid ? 'Invalid email' : null,
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
          ),
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
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Container(
            margin:  const EdgeInsets.only(left: 20, right: 20),
            child: TextFormField(
              key: const Key('loginForm_passwordInput_textField'),
              onChanged: (password) =>
                  context.read<LoginCubit>().passwordChanged(password),
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: '',
                errorText: state.password.invalid
                    ? 'Minimum eight characters, at least one letter and one number'
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
            )
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      // buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('loginForm_continue_raisedButton'),
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  onSurface: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  primary: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: state.status.isValidated
                    ? () => context.read<LoginCubit>().logInWithCredentials()
                    : null,
              );
      },
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      key: const Key('loginForm_googleLogin_raisedButton'),
      label: const Text(
        'SIGN IN WITH GOOGLE',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        primary: theme.colorScheme.secondary,
      ),
      icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
      onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
    );
  }
}

class _FacebookLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      key: const Key('loginForm_facebookLogin_raisedButton'),
      label: const Text(
        'SIGN IN WITH FACEBOOK',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        primary: theme.colorScheme.secondary,
      ),
      icon: const Icon(FontAwesomeIcons.facebook, color: Colors.white),
      onPressed: () => context.read<LoginCubit>().logInWithFacebook(),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      key: const Key('loginForm_createAccount_flatButton'),
      onPressed: () => Navigator.of(context).push<void>(SignUpPage.route()),
      child: Text(
        'CREATE ACCOUNT',
        style: TextStyle(color: theme.colorScheme.secondary),
      ),
    );
  }
}

class _ForgetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      key: const Key('loginForm_forgetAccount_flatButton'),
      onPressed: () => Navigator.of(context).push<void>(ResetAccountPage.route()),
      child: Text(
        'FORGETTING ACCOUNT',
        style: TextStyle(color: theme.colorScheme.secondary),
      ),
    );
  }
}

