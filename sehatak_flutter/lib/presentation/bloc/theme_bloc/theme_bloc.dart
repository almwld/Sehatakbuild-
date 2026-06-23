import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class ThemeState {}

class ThemeLight extends ThemeState {}

class ThemeDark extends ThemeState {}

// Events
abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeLight()) {
    on<ToggleTheme>((event, emit) {
      if (state is ThemeLight) {
        emit(ThemeDark());
      } else {
        emit(ThemeLight());
      }
    });
  }
}
