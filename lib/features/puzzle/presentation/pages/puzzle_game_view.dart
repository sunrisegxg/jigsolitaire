import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:jigsolitaire/core/services/interaction_service.dart';
import 'package:jigsolitaire/features/game_progress/domain/repositories/game_progress_repository.dart';
import 'package:jigsolitaire/features/game_progress/presentation/bloc/game_progress_bloc.dart';
import 'package:jigsolitaire/features/game_progress/presentation/bloc/game_progress_event.dart';
import 'package:jigsolitaire/features/game_progress/presentation/bloc/game_progress_state.dart';
import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_level_config.dart';
import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_route_result.dart';
import 'package:jigsolitaire/features/puzzle/domain/entities/puzzle_session.dart';
import 'package:jigsolitaire/features/puzzle/presentation/widgets/setting/game_setting_dialog.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../injection_container.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import '../bloc/puzzle_state.dart';
import '../widgets/game_app_bar/game_app_bar.dart';
import '../widgets/level_clear/coin_wallet.dart';
import '../widgets/level_clear/flying_coin_layer.dart';
import '../widgets/level_clear/level_clear_banner.dart';
import '../widgets/level_clear/level_clear_reward_panel.dart';
import '../widgets/level_mode_intro_overlay.dart';
import '../widgets/puzzle_board_widget.dart';

class PuzzleGameView extends StatefulWidget {
  final PuzzleLevelConfig config;
  const PuzzleGameView({required this.config, super.key});

  @override
  State<PuzzleGameView> createState() => _PuzzleGameViewState();
}

class _PuzzleGameViewState extends State<PuzzleGameView>
    with TickerProviderStateMixin {
  late int _rewardCoins = 0;

  // Thay số này bằng số tiền lấy từ Bloc/repository nếu dự án đã lưu tiền.
  late int _walletCoins = 0;
  late int _creditedCoins = 0;

  final GlobalKey _rootStackKey = GlobalKey();
  final GlobalKey _rewardKey = GlobalKey();
  final GlobalKey _walletKey = GlobalKey();

  late final AnimationController _bannerController;
  late final AnimationController _rewardController;
  late final AnimationController _coinFlyController;
  late final AnimationController _walletPulseController;

  late final Animation<double> _bannerOpacity;
  late final Animation<Offset> _bannerSlide;
  late final Animation<double> _bannerWidthScale;
  late final Animation<double> _bannerHeightScale;
  late final Animation<double> _bannerTextReveal;

  late final Animation<double> _rewardOpacity;
  late final Animation<double> _rewardScale;
  late final Animation<double> _nextButtonOpacity;
  late final Animation<Offset> _nextButtonSlide;
  late final Animation<double> _walletScale;

  Timer? _confettiTimer;

  Offset _coinStart = Offset.zero;
  Offset _coinEnd = Offset.zero;

  bool _showRewardPanel = false;
  bool _showFlyingCoins = false;
  bool _nextButtonLocked = false;

  @override
  void initState() {
    super.initState();
    _initializeBannerAnimations();
    _initializeRewardAnimations();
    _initializeCoinAnimations();
  }

  void _initializeBannerAnimations() {
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _bannerOpacity = CurvedAnimation(
      parent: _bannerController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _bannerSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _bannerController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
          ),
        );

    _bannerWidthScale =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.25,
              end: 1.08,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 75,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.08,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 25,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _bannerController,
            curve: const Interval(0.1, 1.0),
          ),
        );

    _bannerHeightScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _bannerController,
        curve: const Interval(0.1, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _bannerTextReveal = CurvedAnimation(
      parent: _bannerController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );
  }

  void _initializeRewardAnimations() {
    _rewardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _rewardOpacity = CurvedAnimation(
      parent: _rewardController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _rewardScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _rewardController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _nextButtonOpacity = CurvedAnimation(
      parent: _rewardController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _nextButtonSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _rewardController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
          ),
        );
  }

  void _initializeCoinAnimations() {
    _coinFlyController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1350),
          )
          ..addListener(_updateWalletDuringFlight)
          ..addStatusListener(_onCoinAnimationStatusChanged);

    _walletPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _walletScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 55,
      ),
    ]).animate(_walletPulseController);
  }

  @override
  void dispose() {
    _stopContinuousConfetti();

    _coinFlyController
      ..removeListener(_updateWalletDuringFlight)
      ..removeStatusListener(_onCoinAnimationStatusChanged)
      ..dispose();

    _bannerController.dispose();
    _rewardController.dispose();
    _walletPulseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PuzzleBloc, PuzzleState>(
      listenWhen: (previous, current) {
        return !previous.isCompleted && current.isCompleted;
      },
      listener: (context, state) {
        _walletCoins = context.read<GameProgressBloc>().state.progress.coins;
        _rewardCoins = widget.config.rewardCoins;

        _playLevelClearSequence();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppConstants.puzzleBackgroundColor,
          body: SafeArea(
            child: Stack(
              key: _rootStackKey,
              clipBehavior: Clip.none,
              children: [
                _buildGameContent(state.isCompleted, widget.config),

                LevelModeIntroOverlay(
                  mode: widget.config.mode,
                  visible:
                      state.phase == PuzzleGamePhase.loading ||
                      state.phase == PuzzleGamePhase.dealing ||
                      state.phase == PuzzleGamePhase.flipping,
                ),

                LevelClearBanner(
                  assetPath: AppConstants.levelClearBanner,
                  controller: _bannerController,
                  opacity: _bannerOpacity,
                  slide: _bannerSlide,
                  widthScale: _bannerWidthScale,
                  heightScale: _bannerHeightScale,
                  textReveal: _bannerTextReveal,
                ),

                if (_showRewardPanel)
                  Positioned(
                    top: 92,
                    right: 20,
                    child: ScaleTransition(
                      scale: _walletScale,
                      child: CoinWallet(key: _walletKey, coins: _walletCoins),
                    ),
                  ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: LevelClearRewardPanel(
                    rewardKey: _rewardKey,
                    rewardCoins: _rewardCoins,
                    rewardOpacity: _rewardOpacity,
                    rewardScale: _rewardScale,
                    buttonOpacity: _nextButtonOpacity,
                    buttonSlide: _nextButtonSlide,
                    isLocked: _nextButtonLocked,
                    onNextPressed: _onNextPressed,
                  ),
                ),

                if (_showFlyingCoins)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: FlyingCoinLayer(
                        animation: _coinFlyController,
                        start: _coinStart,
                        end: _coinEnd,
                        coinCount: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameContent(bool isCompleted, PuzzleLevelConfig config) {
    return Column(
      children: [
        const SizedBox(height: 24),
        GameAppBar(
          isCompleted: isCompleted,
          onSettingsPressed: _showSettingsDialog,
          config: config,
        ),
        const SizedBox(height: 32),
        _buildPuzzleBoard(),
      ],
    );
  }

  //Settings dialog
  void _onHomePressed() {
    Navigator.of(context).pop();
  }

  void _onRestartPressed() {
    _resetPuzzle();
  }

  Future<void> _showSettingsDialog() async {
    await context.read<InteractionService>().tap();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => GameSettingDialog(
        onHomePressed: _onHomePressed,
        onRestartPressed: _onRestartPressed,
      ),
    );
  }

  Widget _buildPuzzleBoard() {
    return Center(
      child: AspectRatio(
        aspectRatio: AppConstants.puzzleAspectRatio,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: PuzzleBoardWidget(),
        ),
      ),
    );
  }

  Future<void> _playLevelClearSequence() async {
    _stopContinuousConfetti();

    _bannerController.reset();
    _rewardController.reset();
    _coinFlyController.reset();

    if (mounted) {
      setState(() {
        _showRewardPanel = false;
        _showFlyingCoins = false;
        _nextButtonLocked = false;
        _creditedCoins = 0;
      });
    }

    _firstLaunchConfetti();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    await _bannerController.forward(from: 0);

    if (!mounted) return;
    setState(() {
      _showRewardPanel = true;
    });

    await _rewardController.forward(from: 0);

    if (!mounted) return;
    _startContinuousConfetti();
  }

  void _onNextPressed() async {
    if (_rewardCoins == 0) {
      if (_nextButtonLocked) return;
      setState(() => _nextButtonLocked = true);
      await _finishLevel();
      return;
    }
    if (_nextButtonLocked || !_calculateCoinPositions()) return;

    _stopContinuousConfetti();

    setState(() {
      _nextButtonLocked = true;
      _showFlyingCoins = true;
      _creditedCoins = 0;
    });

    // Cụm +16 và nút Next thu nhỏ/fade out trong lúc xu bắt đầu bay.
    _rewardController.reverse();
    _coinFlyController.forward(from: 0);
  }

  bool _calculateCoinPositions() {
    final rootObject = _rootStackKey.currentContext?.findRenderObject();
    final rewardObject = _rewardKey.currentContext?.findRenderObject();
    final walletObject = _walletKey.currentContext?.findRenderObject();

    if (rootObject is! RenderBox ||
        rewardObject is! RenderBox ||
        walletObject is! RenderBox ||
        !rootObject.hasSize ||
        !rewardObject.hasSize ||
        !walletObject.hasSize) {
      return false;
    }

    final rewardGlobal = rewardObject.localToGlobal(
      rewardObject.size.center(Offset.zero),
    );
    final walletGlobal = walletObject.localToGlobal(
      walletObject.size.center(Offset.zero),
    );

    _coinStart = rootObject.globalToLocal(rewardGlobal);
    _coinEnd = rootObject.globalToLocal(walletGlobal);

    return true;
  }

  void _updateWalletDuringFlight() {
    // Chỉ bắt đầu tăng số khi các đồng xu đã bay gần tới ví.
    final arrivalProgress = ((_coinFlyController.value - 0.42) / 0.58).clamp(
      0.0,
      1.0,
    );
    final targetCredited = (arrivalProgress * _rewardCoins).floor();

    if (!mounted || targetCredited <= _creditedCoins) return;

    final difference = targetCredited - _creditedCoins;

    setState(() {
      _walletCoins += difference;
      // _displayedCoins += difference; xoa dong tren
      _creditedCoins = targetCredited;
    });
  }

  void _onCoinAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _finishCoinAnimation();
    }
  }

  Future<void> _finishCoinAnimation() async {
    if (!mounted) return;

    final remainingCoins = _rewardCoins - _creditedCoins;

    setState(() {
      _walletCoins += remainingCoins;
      _creditedCoins = _rewardCoins;
      _showFlyingCoins = false;
      _showRewardPanel = false;
    });

    await _walletPulseController.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 180));

    if (!mounted) return;

    await _finishLevel();
  }

  Future<void> _finishLevel() async {
    final levelConfig = context.read<PuzzleBloc>().state.levelConfig;
    if (levelConfig == null) {
      return;
    }
    final session = levelConfig.session;
    final progressBloc = context.read<GameProgressBloc>();
    if (session is CampaignPuzzleSession) {
      progressBloc.add(
        CampaignSessionCompleted(
          level: session.level.level,
          rewardCoins: session.level.rewardCoins,
          isReplay: session.isReplay,
        ),
      );
    } else if (session is MasterPuzzleSession) {
      progressBloc.add(
        MasterSessionCompleted(
          levelId: session.level.id,
          isReplay: session.isReplay,
        ),
      );
    }

    final operationState = await progressBloc.stream.firstWhere(
      (state) =>
          state.operationStatus == ProgressOperationStatus.success ||
          state.operationStatus == ProgressOperationStatus.failure,
    );
    if (!mounted) return;
    if (operationState.operationStatus == ProgressOperationStatus.failure) {
      setState(() => _nextButtonLocked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            operationState.errorMessage ?? 'Could not save progress.',
          ),
        ),
      );
      return;
    }

    var firstCompletion = false;
    var collectionCompleted = false;
    String? completedCollectionId;
    if (session is CampaignPuzzleSession) {
      final outcome = operationState.operationResult;
      if (outcome is CampaignCompletionOutcome) {
        firstCompletion = outcome.firstCompletion;
      }
      final collection = InjectionContainer.contentCatalog.collectionForLevel(
        session.level.level,
      );
      collectionCompleted =
          firstCompletion &&
          collection != null &&
          collection.isFullyAvailable &&
          session.level.level == collection.endLevel;
      completedCollectionId = collectionCompleted ? collection.id : null;
    } else if (session is MasterPuzzleSession) {
      final outcome = operationState.operationResult;
      if (outcome is MasterCompletionOutcome) {
        firstCompletion = outcome.firstCompletion;
      }
    }

    Navigator.of(context).pop(
      PuzzleCompletedResult(
        session: session,
        firstCompletion: firstCompletion,
        collectionCompleted: collectionCompleted,
        completedCollectionId: completedCollectionId,
      ),
    );
  }

  // void _goToNextLevel() {
  //   _bannerController.reset();
  //   _rewardController.reset();
  //   _coinFlyController.reset();

  //   setState(() {
  //     _nextButtonLocked = false;
  //     _creditedCoins = 0;
  //   });

  //   // Hiện tại dùng event reset để tạo lượt chơi mới.
  // }

  void _resetPuzzle() {
    _stopContinuousConfetti();

    _bannerController.reset();
    _rewardController.reset();
    _coinFlyController.reset();
    _walletPulseController.reset();

    setState(() {
      _showRewardPanel = false;
      _showFlyingCoins = false;
      _nextButtonLocked = false;
      _creditedCoins = 0;
    });

    context.read<PuzzleBloc>().add(const PuzzleResetRequested());
  }

  void _firstLaunchConfetti() {
    const colors = [
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
    ];

    void launchConfetti(double x) {
      Confetti.launch(
        context,
        options: ConfettiOptions(
          particleCount: 80,
          spread: 30,
          startVelocity: 30,
          gravity: -0.5,
          ticks: 300,
          x: x,
          y: 0.75,
          colors: colors,
        ),
      );
    }

    launchConfetti(0.25);
    launchConfetti(0.75);
  }

  void _startContinuousConfetti() {
    _stopContinuousConfetti();

    const colors = [
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
    ];

    _launchFallingConfetti(colors);

    _confettiTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        _launchFallingConfetti(colors);
      }
    });
  }

  void _launchFallingConfetti(List<Color> colors) {
    Confetti.launch(
      context,
      options: ConfettiOptions(
        particleCount: 4,
        spread: 180,
        startVelocity: 10,
        gravity: 0.2,
        ticks: 600,
        x: Random().nextDouble(),
        y: -0.05,
        colors: colors,
      ),
    );
  }

  void _stopContinuousConfetti() {
    _confettiTimer?.cancel();
    _confettiTimer = null;
  }
}
