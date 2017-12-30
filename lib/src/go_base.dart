library go;

import 'dart:async';
import 'dart:isolate';

part 'delegate.dart';

/// A one-shot task that takes a parameter [param] and returns result of type [R].
typedef FutureOr<R> Task<R, P>(P param);

/// Executes [task] on another isolate with given parameter [param] and returns
/// result of type [R].
///
/// Example:
///
///     int twice(int a) => a * 2;
///
///     main() async {
///       print(await go(twice, 5));  // => 10
///     }
Future<R> go<R, P>(Task<R, P> task, P params) async {
  final receivePort = new ReceivePort();
  final isolate = await Isolate.spawn(
      _delegate, new _DelegateParams(task, params, receivePort.sendPort));
  final R result = await receivePort.first;
  await isolate.kill();
  return result;
}

R _goSync<R, P>(Task<R, P> task, P params) {
   final Future<R> result = go<R, P>(task, params);
   // TODO
}

Task<R, P> asTask<R, P>(Task<R, P> task) => (P params) => go(task, params);
