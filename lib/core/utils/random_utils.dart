import 'dart:math';

class RandomUtils {
  const RandomUtils._();

  static List<T> shuffled<T>(List<T> items, {Random? random}) {
    final result = List<T>.from(items);
    result.shuffle(random ?? Random());
    return result;
  }
}
