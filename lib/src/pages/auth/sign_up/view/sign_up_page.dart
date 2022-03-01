import 'package:authentication_repository/authentication_repository.dart';
import 'package:biplus_media/src/widgets/gradient_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../sign_up.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SignUpPage());
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Sign Up'),
          centerTitle: true,
          backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          elevation: 0,
        ),
        body: BlocProvider<SignUpCubit>(
            create: (_) => SignUpCubit(context.read<AuthenticationRepository>()),
            child: const SignUpForm(),
        ),
      )
    );
  }
}