import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../../game_progress/presentation/bloc/game_progress_state.dart';
import '../../../puzzle/domain/entities/puzzle_route_result.dart';
import '../../../puzzle/domain/entities/puzzle_session.dart';
import '../../../puzzle/presentation/pages/puzzle_game_page.dart';
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
  String? _displayedCollectionId;
  bool _interactionLocked = false;
  int _dealIndex = 25;
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
    if (!mounted ||
        result is! PuzzleCompletedResult ||
        !result.collectionCompleted) {
      return;
    }
    await _runCollectionCompletion(result.completedCollectionId!);
  }

  Future<void> _confirmReplay(int level) async {
    if (_interactionLocked) return;
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

  Future<void> _runCollectionCompletion(String collectionId) async {
    if (_interactionLocked) return;
    final collection = InjectionContainer.contentCatalog.collectionById(
      collectionId,
    );
    if (collection == null) return;
    setState(() {
      _interactionLocked = true;
      _displayedCollectionId = collectionId;
      _dealIndex = 25;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _calculateFlightOffset();
    await _collectionController.forward(from: 0);
    if (!mounted) return;

    final collections = InjectionContainer.contentCatalog.campaignCollections;
    final nextIndex =
        collections.indexWhere((item) => item.id == collectionId) + 1;
    final next = nextIndex > 0 && nextIndex < collections.length
        ? collections[nextIndex]
        : null;
    setState(() {
      _displayedCollectionId = next?.id;
      _dealIndex = 0;
    });
    if (next != null && next.isAvailable) {
      for (var index = 1; index <= 25; index++) {
        await Future<void>.delayed(const Duration(milliseconds: 70));
        if (!mounted) return;
        setState(() => _dealIndex = index);
      }
    }
    if (!mounted) return;
    setState(() {
      _interactionLocked = false;
      _displayedCollectionId = null;
      _dealIndex = 25;
    });
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
    return BlocBuilder<GameProgressBloc, GameProgressState>(
      builder: (context, state) {
        final progress = state.progress;
        final catalog = InjectionContainer.contentCatalog;
        final finalLevel = catalog.finalAvailableCampaignLevel;
        final allAvailableCompleted =
            finalLevel == null || progress.completedLevelCount >= finalLevel;
        final naturalCollection =
            catalog.collectionForLevel(
              allAvailableCompleted
                  ? progress.completedLevelCount
                  : progress.currentLevel,
            ) ??
            catalog.campaignCollections.first;
        final collection = _displayedCollectionId == null
            ? naturalCollection
            : catalog.collectionById(_displayedCollectionId!) ??
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
                  absorbing: _interactionLocked,
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
                                      progress.completedLevelCount,
                                  onCompletedLevelTap: _confirmReplay,
                                  gapFactor: gapFactor,
                                  frameOpacity: gapFactor,
                                  dealIndex: _dealIndex,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      HomeBottomBar(
                        currentLevel: progress.currentLevel,
                        isAllCompleted: allAvailableCompleted,
                        onPlayPressed: allAvailableCompleted
                            ? _showComingSoon
                            : () => _openCurrentLevel(progress.currentLevel),
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
