import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import 'home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InjectionContainer.createHomeBloc(context.read<GameProgressBloc>()),
      child: const HomeView(),
    );
  }
}
