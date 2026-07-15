import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsolitaire/only_one_point_widget.dart';

import 'app.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phải khởi tạo service trước khi build App.
  await InjectionContainer.initialize();

  Bloc.observer = AppBlocObserver();

  runApp(const OnlyOnePointerRecognizerWidget(child: App()));
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
