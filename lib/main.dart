import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/only_one_point_widget.dart';

import 'app.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  runApp(
    OnlyOnePointerRecognizerWidget(
      child: RepositoryProvider(create: (context) => App(), child: const App()),
    ),
  );
}

/// Logs all BLoC state transitions globally.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint(
      '[${bloc.runtimeType}] '
      '${change.currentState.runtimeType} -> '
      '${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('[${bloc.runtimeType}] ERROR: $error');
    super.onError(bloc, error, stackTrace);
  }
}
