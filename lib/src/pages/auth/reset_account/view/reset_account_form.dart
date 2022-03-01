import 'package:biplus_media/src/pages/auth/reset_account/cubit/reset_account_cubit.dart';
import 'package:biplus_media/src/pages/auth/reset_account/cubit/reset_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class ResetAccountForm extends StatelessWidget {
  const ResetAccountForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetAccountCubit, ResetAccountState>(
        listener: (context, state) {
          if (state.status.isSubmissionSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text(state.errorMessage ??
                        'Please check out the reset instruction in your email!')),
              );
            Navigator.of(context).pop();
          } else if (state.status.isSubmissionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content:
                        Text(state.errorMessage ?? 'Reset password failure')),
              );
          }
        },
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _EmailInput(),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Reset Password'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  primary: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {
                  context.read<ResetAccountCubit>().resetFormSubmitted();
                },
              )
            ],
          ),
        ));
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetAccountCubit, ResetAccountState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: TextField(
            key: const Key('resetForm_emailInput_textField'),
            onChanged: (email) =>
                context.read<ResetAccountCubit>().emailChanged(email),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
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
          )
        );
      },
    );
  }
}
