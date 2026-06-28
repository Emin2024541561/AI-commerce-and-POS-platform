import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_client.dart';
import 'state/app_bloc.dart';
import 'models/models.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/home_shell.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(SmartAiPosApp(bloc: AppBloc(ApiClient())));
}

class SmartAiPosApp extends StatelessWidget {
  const SmartAiPosApp({super.key, required this.bloc});

  final AppBloc bloc;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      bloc: bloc,
      child: ValueListenableBuilder<AppState>(
        valueListenable: bloc,
        builder: (context, state, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart AI POS',
            themeMode: state.themeMode,
           theme: AppTheme.light,

darkTheme: AppTheme.dark,
   home: state.session == null
    ? const WelcomeScreen()
    : state.session!.user.role == UserRole.customer
        ? const CustomerShell()
        : const HomeShell(),
          );
        },
      ),
    );
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.bloc, required super.child});

  final AppBloc bloc;

  static AppBloc of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.bloc;

  @override
  bool updateShouldNotify(AppScope oldWidget) => bloc != oldWidget.bloc;
}
