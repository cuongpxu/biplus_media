import 'package:authentication_repository/authentication_repository.dart';
import 'package:biplus_media/src/pages/auth/reset_account/cubit/reset_account_cubit.dart';
import 'package:biplus_media/src/pages/auth/reset_account/view/reset_account_form.dart';
import 'package:biplus_media/src/widgets/gradient_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetAccountPage extends StatelessWidget {
  static String id = 'forgot-password';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ResetAccountPage());
  }

  const ResetAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Reset Password'),
              centerTitle: true,
              backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondary,
              elevation: 0,
            ),
            body: BlocProvider<ResetAccountCubit>(
              create: (_) => ResetAccountCubit(context.read<AuthenticationRepository>()),
              child: const ResetAccountForm(),
            )
        )
    );
  }
}