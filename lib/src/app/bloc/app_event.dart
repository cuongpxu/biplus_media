part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class AppUserChanged extends AppEvent {
  const AppUserChanged(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}