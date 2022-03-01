import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../widgets/gradient_containers.dart';
import '../login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: LoginPage());

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Dashboard'),
          centerTitle: true,
          backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          elevation: 0,
        ),
        body: BlocProvider(
            create: (_) => LoginCubit(context.read<AuthenticationRepository>()),
            child: const LoginForm()),
      )
    );
  }
}
