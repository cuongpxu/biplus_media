import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../app/bloc/app_bloc.dart';
import '../../../widgets/gradient_containers.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return GradientContainer(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text("Edit Profile"),
              centerTitle: true,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondary,
              elevation: 0,
            ),
            body: BlocProvider(
                create: (_) => EditProfileCubit(context.read<AuthenticationRepository>()),
                child: BlocBuilder<AppBloc, AppState>(
                    builder: (appBloc, appState) => ListView(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {

                                  },
                                  child: CircleAvatar(
                                    minRadius: 60,
                                    backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                    child: const CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          'https://radio.biplus.com.vn/songs/radio_000.png'),
                                      minRadius: 50,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            // Text(
                            //   appState.user.name,
                            //   style: const TextStyle(
                            //       fontSize: 22.0, color: Colors.white),
                            // ),
                          ],
                        ),
                        _NameInput(),
                        _PhoneInput(),
                        _EmailInput(),
                        ListTile(
                          title: Text(
                            "Gender",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 12.0),
                          ),
                          subtitle: const Text(
                            // appState.user.gender == 0 ? "Female" : "Male",
                            "Male",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(
                            "DOB",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 12.0),
                          ),
                          subtitle: Text(
                            DateFormat("dd-MM-yyyy")
                                .format(appState.user.birthday!),
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ),
                        const Divider(),
                      ],
                    ))
            )

            ));
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: TextField(
            key: const Key('editProfileForm_emailInput_textField'),
            onChanged: (email) => context.read<EditProfileCubit>().emailChanged(email),
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

class _NameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: TextField(
            key: const Key('editProfileForm_nameInput_textField'),
            onChanged: (name) => context.read<EditProfileCubit>().nameChanged(name),
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              //  labelStyle: TextStyle(color: Colors.white),
              labelText: 'Name',
              helperText: '',
              errorText: state.name.invalid ? 'Invalid name' : null,
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

class _PhoneInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: TextField(
            key: const Key('editProfileForm_phoneInput_textField'),
            onChanged: (phone) => context.read<EditProfileCubit>().phoneChanged(phone),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              //  labelStyle: TextStyle(color: Colors.white),
              labelText: 'Phone',
              helperText: '',
              errorText: state.phone.invalid ? 'Invalid phone number' : null,
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