import 'package:biplus_media/src/app/bloc/app_bloc.dart';
import 'package:biplus_media/src/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: HomePage());

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return Align(
      alignment: const Alignment(0, -1 / 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Avatar(photo: user.avatar),
          const SizedBox(height: 4),
          Text(user.email ?? '', style: textTheme.headline6),
          const SizedBox(height: 4),
          Text(user.name ?? '', style: textTheme.headline5),
        ],
      ),
    );
  }
}