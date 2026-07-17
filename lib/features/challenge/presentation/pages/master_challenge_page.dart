import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/game_dialog.dart';
import '../../../../core/services/interaction_service.dart';
import '../../../../injection_container.dart';
import '../../../content/domain/entities/master_content.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../../puzzle/domain/entities/puzzle_route_result.dart';
import '../../../puzzle/presentation/pages/puzzle_game_page.dart';
import '../../../puzzle/presentation/widgets/level_clear/coin_wallet.dart';
import '../bloc/master_challenge_bloc.dart';
import '../bloc/master_challenge_event.dart';
import '../bloc/master_challenge_state.dart';

class MasterChallengePage extends StatelessWidget {
  const MasterChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectionContainer.createMasterChallengeBloc(
        context.read<GameProgressBloc>(),
      ),
      child: const _MasterChallengeView(),
    );
  }
}

class _MasterChallengeView extends StatelessWidget {
  const _MasterChallengeView();

  Future<void> _handleAction(BuildContext context, MasterAction action) async {
    final bloc = context.read<MasterChallengeBloc>();
    switch (action.type) {
      case MasterActionType.confirmPurchase:
        final level = action.level!;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => GameDialog(
            icon: Icons.lock_open_rounded,
            title: 'Unlock Master Level ${level.id}?',
            message:
                'Spend ${level.unlockCost} coins to unlock this level permanently?',
            actions: [
              GameDialogButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context, false),
              ),
              GameDialogButton(
                label: 'Unlock',
                primary: true,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
        if (!context.mounted) return;
        if (confirmed == true) {
          bloc.add(MasterPurchaseConfirmed(level));
        } else {
          bloc.add(const MasterActionHandled());
        }
        return;
      case MasterActionType.openPuzzle:
        bloc.add(const MasterActionHandled());
        final config = InjectionContainer.puzzleLevelConfigService.master(
          id: action.level!.id,
          purpose: action.purpose!,
        );
        await Navigator.push<PuzzleRouteResult>(
          context,
          MaterialPageRoute(builder: (_) => PuzzleGamePage(config: config)),
        );
        return;
      case MasterActionType.showMessage:
        await showDialog<void>(
          context: context,
          builder: (context) => GameDialog(
            icon: action.title == 'Not Enough Coins'
                ? Icons.monetization_on_outlined
                : Icons.error_outline_rounded,
            title: action.title!,
            message: action.message!,
            actions: [
              GameDialogButton(
                label: 'OK',
                primary: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        if (context.mounted) {
          bloc.add(const MasterActionHandled());
        }
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterChallengeBloc, MasterChallengeState>(
      listenWhen: (previous, current) =>
          previous.actionId != current.actionId && current.action != null,
      listener: (context, state) => _handleAction(context, state.action!),
      builder: (context, state) {
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
                top: 40,
                right: 20,
                child: CoinWallet(coins: state.progress.coins),
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
                              onPressed: state.purchasingLevelId == null
                                  ? () async {
                                      await context
                                          .read<InteractionService>()
                                          .tap();
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
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
                    if (state.allAvailableCompleted)
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
                        itemCount: state.cards.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 12,
                              childAspectRatio: .62,
                            ),
                        itemBuilder: (context, index) {
                          final card = state.cards[index];
                          return _MasterCard(
                            data: card,
                            busy: state.purchasingLevelId == card.level.id,
                            onTap: state.purchasingLevelId == null
                                ? () async {
                                    await context
                                        .read<InteractionService>()
                                        .tap();
                                    if (context.mounted) {
                                      context.read<MasterChallengeBloc>().add(
                                        MasterCardTapped(card.level.id),
                                      );
                                    }
                                  }
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
      },
    );
  }
}

class _MasterCard extends StatelessWidget {
  const _MasterCard({
    required this.data,
    required this.busy,
    required this.onTap,
  });

  final MasterCardViewData data;
  final bool busy;
  final VoidCallback? onTap;
  MasterLevelDefinition get level => data.level;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _buttonStyle;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(level.imageAsset, fit: BoxFit.cover),
            if (data.state == MasterCardState.locked ||
                data.state == MasterCardState.comingSoon)
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
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
            if (data.state == MasterCardState.locked)
              const Center(
                child: Icon(Icons.lock, size: 42, color: Colors.white),
              ),
            if (busy)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: buttonStyle.colors,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: buttonStyle.borderColor, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        buttonStyle.icon,
                        color: buttonStyle.foregroundColor,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: buttonStyle.foregroundColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _label => switch (data.state) {
    MasterCardState.locked => 'Locked',
    MasterCardState.purchasable => '${level.unlockCost} coins',
    MasterCardState.unlocked => 'Play',
    MasterCardState.completed => 'Completed',
    MasterCardState.comingSoon => 'Coming soon',
  };

  _MasterButtonStyle get _buttonStyle => switch (data.state) {
    MasterCardState.locked => const _MasterButtonStyle(
      colors: [Color(0xFF7D8588), Color(0xFF4F5659)],
      borderColor: Color(0xFFB8BEC0),
      foregroundColor: Colors.white,
      icon: Icons.lock_rounded,
    ),
    MasterCardState.purchasable => const _MasterButtonStyle(
      colors: [Color(0xFFFFD95A), Color(0xFFF2A900)],
      borderColor: Color(0xFFFFF0A8),
      foregroundColor: Color(0xFF5B3A00),
      icon: Icons.monetization_on_rounded,
    ),
    MasterCardState.unlocked => const _MasterButtonStyle(
      colors: [Color(0xFF4FD3FF), Color(0xFF0077B6)],
      borderColor: Color(0xFFA9EAFF),
      foregroundColor: Colors.white,
      icon: Icons.play_arrow_rounded,
    ),
    MasterCardState.completed => const _MasterButtonStyle(
      colors: [Color(0xFF56C596), Color(0xFF087F5B)],
      borderColor: Color(0xFFB7F5DA),
      foregroundColor: Colors.white,
      icon: Icons.check_circle_rounded,
    ),
    MasterCardState.comingSoon => const _MasterButtonStyle(
      colors: [Color(0xFF9C6ADE), Color(0xFF5D35A3)],
      borderColor: Color(0xFFD8C4F5),
      foregroundColor: Colors.white,
      icon: Icons.schedule_rounded,
    ),
  };
}

class _MasterButtonStyle {
  const _MasterButtonStyle({
    required this.colors,
    required this.borderColor,
    required this.foregroundColor,
    required this.icon,
  });

  final List<Color> colors;
  final Color borderColor;
  final Color foregroundColor;
  final IconData icon;
}
