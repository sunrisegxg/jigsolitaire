import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/interaction_service.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InteractionService>.value(
          value: InjectionContainer.interactionService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                InjectionContainer.createSettingsBloc()
                  ..add(const SettingsStarted()),
          ),
          BlocProvider(
            create: (_) => InjectionContainer.createGameProgressBloc(),
          ),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Jigsolitaire',
          home: HomePage(),
        ),
      ),
    );
  }
}
