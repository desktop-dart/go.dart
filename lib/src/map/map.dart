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
Future<List<R>> goMap<R, P>(Task<R, P> task, Iterable<P> param,
    {Encoder<P> paramEncoder,
    Decoder<P> paramDecoder,
    Encoder<R> resultEncoder,
    Decoder<R> resultDecoder}) async {
  final futures = <Future<R>>[];

  for (P p in param) {
    futures.add(go(task, p,
        paramEncoder: paramEncoder,
        paramDecoder: paramDecoder,
        resultEncoder: resultEncoder,
        resultDecoder: resultDecoder));
  }

  return Future.wait(futures);
}
