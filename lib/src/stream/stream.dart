library go.stream;

import 'dart:async';
import 'dart:isolate';

part 'delegate.dart';

/// A one-shot task that takes a parameter [param] and returns result of type [R].
typedef FutureOr<Stream<R>> StreamTask<R, P>(P param);

/// Executes [task] on another isolate with given parameter [param] and returns
/// result of type [R].
///
/// Example:
///
///     Stream<int> fib(int n) async* {
///       int a = 0, b = 1;
///
///       while (b < n) {
///         int newNum = a + b;
///         a = b;
///         b = newNum;
///         yield newNum;
///       }
///     };
///
///     main() async {
///       Stream<int> fs = await stream(fib, 50);
///       await for(int f in fs) {
///         print('Result from remote $f');
///       }
///     }
Future<Stream<R>> stream<R, P>(StreamTask<R, P> task, P param) async {
  final receivePort = new ReceivePort();
  final isolate = await Isolate.spawn(
      _delegate, new _DelegateParams(task, param, receivePort.sendPort));
  final Stream<R> result = receivePort.map((d) => d as R);
  final exitReceivePort = new ReceivePort();
  isolate.addOnExitListener(exitReceivePort.sendPort);
  exitReceivePort.first.then((_) {
    receivePort.close();
  });
  return result;
}

/// Converts [task] to a function that executes [task] on another isolate and
/// return result.
///
/// Example:
///
///     Stream<int> fib(int n) async* {
///       int a = 0, b = 1;
///
///       while (b < n) {
///         int newNum = a + b;
///         a = b;
///         b = newNum;
///         yield newNum;
///       }
///     };
///
///     main() async {
///       final StreamTask fibTask = remoteStream(fib);
///       await for(int f in await fibTask(50)) {
///         print('Result from remote $f');
///       }
///     }
StreamTask<R, P> remoteStream<R, P>(StreamTask<R, P> task) =>
    (P params) => stream<R, P>(task, params);
