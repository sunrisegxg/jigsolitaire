import 'dart:async';
import 'dart:convert';

import 'package:jigsolitaire/features/game_progress/domain/entities/game_progress.dart';
import 'package:jigsolitaire/features/game_progress/domain/repositories/game_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalGameProgressRepository implements GameProgressRepository {
  LocalGameProgressRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _completedLevelCountKey =
      'game_progress.completed_level_count';

  static const String _coinsKey = 'game_progress.coins';
  static const String _aggregateKey = 'game_progress.v2';
  Future<void> _mutationQueue = Future.value();

  @override
  Future<GameProgress> load() async {
    final aggregate = await _preferences.getString(_aggregateKey);
    if (aggregate != null) {
      try {
        return _decode(aggregate);
      } catch (_) {
        // Fall back to the legacy keys without overwriting the malformed value.
      }
    }

    final completedLevelCount =
        await _preferences.getInt(_completedLevelCountKey) ?? 0;

    final coins = await _preferences.getInt(_coinsKey) ?? 0;

    final migrated = GameProgress(
      completedLevelCount: completedLevelCount < 0 ? 0 : completedLevelCount,
      coins: coins < 0 ? 0 : coins,
    );
    await save(migrated);
    return migrated;
  }

  @override
  Future<void> save(GameProgress progress) async {
    await _preferences.setString(_aggregateKey, _encode(progress));
  }

  @override
  Future<CampaignCompletionOutcome> completeCampaignLevel({
    required int level,
    required int rewardCoins,
    required bool isReplay,
  }) {
    return _serialized(() async {
      final progress = await load();
      if (isReplay || level <= progress.completedLevelCount) {
        return CampaignCompletionOutcome(
          progress: progress,
          firstCompletion: false,
        );
      }
      if (level != progress.currentLevel) {
        throw StateError('Only the current campaign level can be completed.');
      }
      final updated = progress.copyWith(
        completedLevelCount: level,
        coins: progress.coins + (rewardCoins < 0 ? 0 : rewardCoins),
      );
      await save(updated);
      return CampaignCompletionOutcome(
        progress: updated,
        firstCompletion: true,
      );
    });
  }

  @override
  Future<MasterPurchaseOutcome> purchaseMasterLevel({
    required int levelId,
    required int unlockCost,
    required bool isAvailable,
    required bool prerequisiteCompleted,
  }) {
    return _serialized(() async {
      final progress = await load();
      if (progress.purchasedMasterLevelIds.contains(levelId)) {
        return MasterPurchaseOutcome(
          status: MasterPurchaseStatus.alreadyPurchased,
          progress: progress,
        );
      }
      if (!isAvailable) {
        return MasterPurchaseOutcome(
          status: MasterPurchaseStatus.unavailable,
          progress: progress,
        );
      }
      if (!prerequisiteCompleted) {
        return MasterPurchaseOutcome(
          status: MasterPurchaseStatus.locked,
          progress: progress,
        );
      }
      if (progress.coins < unlockCost) {
        return MasterPurchaseOutcome(
          status: MasterPurchaseStatus.insufficientCoins,
          progress: progress,
        );
      }
      final updated = progress.copyWith(
        coins: progress.coins - unlockCost,
        purchasedMasterLevelIds: {...progress.purchasedMasterLevelIds, levelId},
      );
      await save(updated);
      return MasterPurchaseOutcome(
        status: MasterPurchaseStatus.purchased,
        progress: updated,
      );
    });
  }

  @override
  Future<MasterCompletionOutcome> completeMasterLevel({
    required int levelId,
    required bool isReplay,
  }) {
    return _serialized(() async {
      final progress = await load();
      if (isReplay || progress.completedMasterLevelIds.contains(levelId)) {
        return MasterCompletionOutcome(
          progress: progress,
          firstCompletion: false,
        );
      }
      if (!progress.purchasedMasterLevelIds.contains(levelId)) {
        throw StateError('Master level must be purchased before completion.');
      }
      final updated = progress.copyWith(
        completedMasterLevelIds: {...progress.completedMasterLevelIds, levelId},
      );
      await save(updated);
      return MasterCompletionOutcome(progress: updated, firstCompletion: true);
    });
  }

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _mutationQueue = _mutationQueue.then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  String _encode(GameProgress progress) => jsonEncode({
    'schemaVersion': 2,
    'completedCampaignLevelCount': progress.completedLevelCount,
    'coins': progress.coins,
    'purchasedMasterLevelIds': progress.purchasedMasterLevelIds.toList()
      ..sort(),
    'completedMasterLevelIds': progress.completedMasterLevelIds.toList()
      ..sort(),
  });

  GameProgress _decode(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    Set<int> ids(String key) => (json[key] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((value) => value.toInt())
        .where((value) => value > 0)
        .toSet();
    final completed = ids('completedMasterLevelIds');
    return GameProgress(
      completedLevelCount:
          ((json['completedCampaignLevelCount'] as num?)?.toInt() ?? 0)
              .clamp(0, 1 << 31)
              .toInt(),
      coins: ((json['coins'] as num?)?.toInt() ?? 0).clamp(0, 1 << 31).toInt(),
      purchasedMasterLevelIds: {
        ...ids('purchasedMasterLevelIds'),
        ...completed,
      },
      completedMasterLevelIds: completed,
    );
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _preferences.remove(_completedLevelCountKey),
      _preferences.remove(_coinsKey),
      _preferences.remove(_aggregateKey),
    ]);
  }

  //===========================Debug methods===========================
  @override
  Future<GameProgress> addDebugCoins(int amount) {
    return _serialized(() async {
      final progress = await load();
      final updated = progress.copyWith(
        coins: progress.coins + (amount < 0 ? 0 : amount),
      );
      await save(updated);
      return updated;
    });
  }

  @override
  Future<GameProgress> advanceDebugCampaignLevel({required int maximumLevel}) {
    return _serialized(() async {
      final progress = await load();
      if (progress.completedLevelCount >= maximumLevel) return progress;
      final updated = progress.copyWith(
        completedLevelCount: progress.completedLevelCount + 1,
      );
      await save(updated);
      return updated;
    });
  }
}
