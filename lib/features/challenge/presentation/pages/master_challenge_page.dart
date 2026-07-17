import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../content/domain/entities/master_content.dart';
import '../../../game_progress/domain/repositories/game_progress_repository.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../../game_progress/presentation/bloc/game_progress_event.dart';
import '../../../game_progress/presentation/bloc/game_progress_state.dart';
import '../../../puzzle/domain/entities/puzzle_route_result.dart';
import '../../../puzzle/domain/entities/puzzle_session.dart';
import '../../../puzzle/presentation/pages/puzzle_game_page.dart';
import '../../../puzzle/presentation/widgets/level_clear/coin_wallet.dart';

enum MasterCardState { locked, purchasable, unlocked, completed, comingSoon }

class MasterChallengePage extends StatefulWidget {
  const MasterChallengePage({super.key});
  @override
  State<MasterChallengePage> createState() => _MasterChallengePageState();
}

class _MasterChallengePageState extends State<MasterChallengePage> {
  int? _purchasingId;

  MasterCardState _stateFor(
    MasterLevelDefinition level,
    GameProgressState state,
  ) {
    final progress = state.progress;
    if (!level.isAvailable) {
      return MasterCardState.comingSoon;
    }
    if (progress.completedMasterLevelIds.contains(level.id)) {
      return MasterCardState.completed;
    }
    if (progress.purchasedMasterLevelIds.contains(level.id)) {
      return MasterCardState.unlocked;
    }
    if (level.id == 1 ||
        progress.completedMasterLevelIds.contains(level.id - 1)) {
      return MasterCardState.purchasable;
    }
    return MasterCardState.locked;
  }

  Future<void> _tapLevel(
    MasterLevelDefinition level,
    MasterCardState cardState,
  ) async {
    switch (cardState) {
      case MasterCardState.purchasable:
        await _confirmPurchase(level);
        return;
      case MasterCardState.unlocked:
        await _openLevel(level, PuzzleSessionPurpose.progress);
        return;
      case MasterCardState.completed:
        await _openLevel(level, PuzzleSessionPurpose.replay);
        return;
      case MasterCardState.locked:
      case MasterCardState.comingSoon:
        return;
    }
  }

  Future<void> _confirmPurchase(MasterLevelDefinition level) async {
    if (_purchasingId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlock Master Level ${level.id}?'),
        content: Text(
          'Spend ${level.unlockCost} coins to unlock this level permanently?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _purchasingId = level.id);
    final bloc = context.read<GameProgressBloc>();
    final prerequisiteCompleted =
        level.id == 1 ||
        bloc.state.progress.completedMasterLevelIds.contains(level.id - 1);
    bloc.add(
      MasterLevelPurchaseRequested(
        levelId: level.id,
        unlockCost: level.unlockCost,
        isAvailable: level.isAvailable,
        prerequisiteCompleted: prerequisiteCompleted,
      ),
    );
    final result = await bloc.stream.firstWhere(
      (state) =>
          state.operationStatus == ProgressOperationStatus.success ||
          state.operationStatus == ProgressOperationStatus.failure,
    );
    if (!mounted) return;
    setState(() => _purchasingId = null);
    final outcome = result.operationResult;
    if (result.operationStatus == ProgressOperationStatus.failure) {
      _showMessage(
        'Purchase failed',
        result.errorMessage ?? 'Please try again.',
      );
    } else if (outcome is MasterPurchaseOutcome &&
        outcome.status == MasterPurchaseStatus.insufficientCoins) {
      _showMessage(
        'Not Enough Coins',
        'You do not have enough coins to unlock this Master Challenge.',
      );
    }
  }

  Future<void> _openLevel(
    MasterLevelDefinition level,
    PuzzleSessionPurpose purpose,
  ) async {
    final config = InjectionContainer.puzzleLevelConfigService.master(
      id: level.id,
      purpose: purpose,
    );
    await Navigator.push<PuzzleRouteResult>(
      context,
      MaterialPageRoute(builder: (_) => PuzzleGamePage(config: config)),
    );
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    final progressState = context.watch<GameProgressBloc>().state;
    final levels = InjectionContainer.contentCatalog.masterLevels;
    final allCompleted = levels
        .where((level) => level.isAvailable)
        .every(
          (level) =>
              progressState.progress.completedMasterLevelIds.contains(level.id),
        );
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: CoinWallet(coins: progressState.progress.coins),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 24,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _purchasingId == null
                              ? () => Navigator.pop(context)
                              : null,
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF056E45),
                            size: 38,
                          ),
                        ),
                      ),
                      const Text(
                        'Master Challenge',
                        style: TextStyle(
                          color: Color(0xFF056E45),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (allCompleted)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          'All Master Challenges completed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('More challenges are coming soon'),
                      ],
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: levels.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 12,
                          childAspectRatio: .62,
                        ),
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final cardState = _stateFor(level, progressState);
                      return _MasterCard(
                        level: level,
                        state: cardState,
                        busy: _purchasingId == level.id,
                        onTap: _purchasingId == null
                            ? () => _tapLevel(level, cardState)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterCard extends StatelessWidget {
  const _MasterCard({
    required this.level,
    required this.state,
    required this.busy,
    required this.onTap,
  });
  final MasterLevelDefinition level;
  final MasterCardState state;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(level.imageAsset, fit: BoxFit.cover),
          if (state == MasterCardState.locked ||
              state == MasterCardState.comingSoon)
            ColoredBox(color: Colors.black.withValues(alpha: .55)),
          Positioned(
            top: 6,
            left: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  'Level ${level.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (state == MasterCardState.locked)
            const Center(
              child: Icon(Icons.lock, size: 42, color: Colors.white),
            ),
          if (busy)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF056E45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  _label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  String get _label => switch (state) {
    MasterCardState.locked => 'Locked',
    MasterCardState.purchasable => '${level.unlockCost} coins',
    MasterCardState.unlocked => 'Play',
    MasterCardState.completed => 'Completed',
    MasterCardState.comingSoon => 'Coming soon',
  };
}
