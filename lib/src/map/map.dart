library go.map;

import 'dart:async';

import '../plain/plain.dart';

/// Launches and returns result of executing [task] given [param].
///
/// Example:
///
///     int twice(int a) => a * 2;
///
///     main() async {
///       print(await goMany(twice, 5, 20));
///     }
Future<List<R>> goMap<R, P>(Task<R, P> task, Iterable<P> param) async {
  final futures = <Future<R>>[];

  for (P p in param) {
    futures.add(go(task, p));
  }

  return Future.wait(futures);
}
