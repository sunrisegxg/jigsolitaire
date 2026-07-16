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

  @override
  Future<GameProgress> load() async {
    final completedLevelCount =
        await _preferences.getInt(_completedLevelCountKey) ?? 0;

    final coins = await _preferences.getInt(_coinsKey) ?? 0;

    return GameProgress(
      completedLevelCount: completedLevelCount < 0 ? 0 : completedLevelCount,
      coins: coins < 0 ? 0 : coins,
    );
  }

  @override
  Future<void> save(GameProgress progress) async {
    await Future.wait([
      _preferences.setInt(
        _completedLevelCountKey,
        progress.completedLevelCount,
      ),
      _preferences.setInt(_coinsKey, progress.coins),
    ]);
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _preferences.remove(_completedLevelCountKey),
      _preferences.remove(_coinsKey),
    ]);
  }
}
