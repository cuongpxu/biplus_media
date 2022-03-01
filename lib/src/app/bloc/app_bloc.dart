import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
        authenticationRepository.currentUser.isNotEmpty
            ? AppState.authenticated(authenticationRepository.currentUser)
            : const AppState.unauthenticated(),
      ) {
    on<AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onUserChanged(AppUserChanged event, Emitter<AppState> emit) {
    _authenticationRepository.currentUser = event.user;
    emit(event.user.isNotEmpty
        ? AppState.authenticated(event.user)
        : const AppState.unauthenticated());
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) async {
    _authenticationRepository.currentUser = User.empty;
    emit(const AppState.unauthenticated());
    await Hive.box('settings').put('user', null);
    await(_authenticationRepository.logOut());
  }
}