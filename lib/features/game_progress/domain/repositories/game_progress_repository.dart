import '../entities/game_progress.dart';

abstract interface class GameProgressRepository {
  Future<GameProgress> load();

  Future<void> save(GameProgress progress);

  Future<void> clear();
}
