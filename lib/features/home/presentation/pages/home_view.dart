import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../../injection_container.dart';
import '../../../puzzle/domain/entities/puzzle_route_result.dart';
import '../../../puzzle/domain/entities/puzzle_session.dart';
import '../../../puzzle/presentation/pages/puzzle_game_page.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../../game_progress/presentation/bloc/game_progress_event.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_grid.dart';
import '../widgets/home_header.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final GlobalKey _collectionButtonKey = GlobalKey();
  final GlobalKey _gridKey = GlobalKey();
  late final AnimationController _collectionController;
  Offset _flightOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _collectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
  }

  @override
  void dispose() {
    _collectionController.dispose();
    super.dispose();
  }

  Future<PuzzleRouteResult?> _openLevel(
    int level,
    PuzzleSessionPurpose purpose,
  ) async {
    final definition = InjectionContainer.contentCatalog.campaignLevel(level);
    if (definition == null || !definition.isAvailable) return null;
    final config = InjectionContainer.puzzleLevelConfigService.campaign(
      level: level,
      purpose: purpose,
    );
    if (!mounted) return null;
    return Navigator.of(context).push<PuzzleRouteResult>(
      MaterialPageRoute(builder: (_) => PuzzleGamePage(config: config)),
    );
  }

  Future<void> _openCurrentLevel(int currentLevel) async {
    final result = await _openLevel(
      currentLevel,
      PuzzleSessionPurpose.progress,
    );
    if (!mounted) return;
    context.read<HomeBloc>().add(HomePuzzleReturned(result));
  }

  Future<void> _confirmReplay(int level) async {
    if (context.read<HomeBloc>().state.interactionLocked) return;
    final replay = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Replay this level?'),
        content: const Text(
          'Replay mode does not grant coins and does not change your current progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Replay'),
          ),
        ],
      ),
    );
    if (replay == true && mounted) {
      await _openLevel(level, PuzzleSessionPurpose.replay);
    }
  }

  Future<void> _playCollectionFlight() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _calculateFlightOffset();
    await _collectionController.forward(from: 0);
    if (!mounted) return;
    context.read<HomeBloc>().add(const HomeCollectionFlightFinished());
    _collectionController.reset();
  }

  void _calculateFlightOffset() {
    final grid = _gridKey.currentContext?.findRenderObject();
    final button = _collectionButtonKey.currentContext?.findRenderObject();
    if (grid is! RenderBox || button is! RenderBox) return;
    final gridCenter = grid.localToGlobal(grid.size.center(Offset.zero));
    final buttonCenter = button.localToGlobal(button.size.center(Offset.zero));
    _flightOffset = buttonCenter - gridCenter;
  }

  void _showComingSoon() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('More levels are coming soon'),
        content: const Text(
          'You have completed every campaign level currently available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.phase != current.phase &&
          current.phase == HomePhase.collectionFlight,
      listener: (context, state) => _playCollectionFlight(),
      builder: (context, homeState) {
        final catalog = InjectionContainer.contentCatalog;
        final naturalCollection =
            catalog.collectionById(homeState.naturalCollectionId ?? '') ??
            catalog.campaignCollections.first;
        final collection = homeState.displayedCollectionId == null
            ? naturalCollection
            : catalog.collectionById(homeState.displayedCollectionId!) ??
                  naturalCollection;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: AbsorbPointer(
                  absorbing: homeState.interactionLocked,
                  child: Column(
                    children: [
                      HomeHeader(collectionButtonKey: _collectionButtonKey),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _collectionController,
                          builder: (context, child) {
                            final value = _collectionController.value;
                            final flight = const Interval(
                              0.58,
                              1,
                              curve: Curves.easeInOutCubic,
                            ).transform(value);
                            return Transform.translate(
                              offset: _flightOffset * flight,
                              child: Transform.scale(
                                scale: 1 - 0.88 * flight,
                                child: Opacity(
                                  opacity: 1 - 0.15 * flight,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            key: _gridKey,
                            child: AnimatedBuilder(
                              animation: _collectionController,
                              builder: (context, _) {
                                final gapFactor =
                                    1 -
                                    const Interval(
                                      0.08,
                                      0.38,
                                      curve: Curves.easeInOut,
                                    ).transform(_collectionController.value);
                                return HomeGrid(
                                  collection: collection,
                                  completedLevelCount:
                                      homeState.completedLevelCount,
                                  onCompletedLevelTap: _confirmReplay,
                                  gapFactor: gapFactor,
                                  frameOpacity: gapFactor,
                                  dealIndex: homeState.dealIndex,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      HomeBottomBar(
                        currentLevel: homeState.currentLevel,
                        isAllCompleted: homeState.allAvailableCompleted,
                        onPlayPressed: homeState.allAvailableCompleted
                            ? _showComingSoon
                            : () => _openCurrentLevel(homeState.currentLevel),
                      ),
                      if (kDebugMode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton.icon(
                                onPressed: homeState.interactionLocked
                                    ? null
                                    : () => context
                                          .read<GameProgressBloc>()
                                          .add(const DebugCoinsAdded()),
                                icon: const Icon(Icons.monetization_on),
                                label: const Text('+1000 Coins'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: homeState.interactionLocked
                                    ? null
                                    : () {
                                        final maximumLevel = InjectionContainer
                                            .contentCatalog
                                            .finalAvailableCampaignLevel;
                                        if (maximumLevel != null) {
                                          context.read<GameProgressBloc>().add(
                                            DebugCampaignLevelAdvanced(
                                              maximumLevel: maximumLevel,
                                            ),
                                          );
                                        }
                                      },
                                icon: const Icon(Icons.skip_next),
                                label: const Text('+1 Level'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
