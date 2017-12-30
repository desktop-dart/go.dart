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
Future<R> go<R, P>(Task<R, P> task, P param) async {
  final receivePort = new ReceivePort();
  final isolate = await Isolate.spawn(
      _delegate, new _DelegateParams(task, param, receivePort.sendPort));
  final R result = await receivePort.first;
  await isolate.kill();
  return result;
}

/// Converts [task] to a function that executes [task] on another isolate and
/// return result.
///
/// Example:
///
///     int twice(int a) => a * 2;
///
///     main() async {
///       Task twiceTask = asTask(twice);
///       print(await twiceTask(5));  // => 10
///       print(await twiceTask(10)); // => 20
///     }
Task<R, P> remoteTask<R, P>(Task<R, P> task) =>
    (P params) => go<R, P>(task, params);
