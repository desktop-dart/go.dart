library go.many;

import 'dart:async';

import '../plain/plain.dart';

/// Launches and returns result of executing [task] [count] number of times
/// concurrently in [count] different isolates.
///
/// Example:
///
///     int twice(int a) => a * 2;
///
///     main() async {
///       print(await goMany(twice, 5, 20));
///     }
Future<List<R>> goMany<R, P>(Task<R, P> task, P param, int count) async {
  final futures = <Future<R>>[];

  for(int i = 0; i < count; i++) {
    futures.add(go(task, param));
  }

  return Future.wait(futures);
}