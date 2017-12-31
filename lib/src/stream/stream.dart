library go.stream;

import 'dart:async';
import 'dart:isolate';

import '../plain/plain.dart';

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
Future<Stream<R>> stream<R, P>(StreamTask<R, P> task, P param,
    {Encoder<P> paramEncoder,
    Decoder<P> paramDecoder,
    Encoder<R> resultEncoder,
    Decoder<R> resultDecoder}) async {
  final receivePort = new ReceivePort();
  final dParams = new _DelegateParams<R, P>(task, param, receivePort.sendPort,
      paramEncoder: paramEncoder,
      paramDecoder: paramDecoder,
      resultEncoder: resultEncoder,
      resultDecoder: resultDecoder);
  final isolate = await Isolate.spawn(_delegate, dParams.toMap);

  final controller = new StreamController<R>();

  final errorReceivePort = new ReceivePort();
  isolate.addErrorListener(errorReceivePort.sendPort);
  errorReceivePort.listen((e) {
    controller.addError(e);
    receivePort.close();
  });

  final exitReceivePort = new ReceivePort();
  isolate.addOnExitListener(exitReceivePort.sendPort);
  exitReceivePort.first.then((_) {
    receivePort.close();
    errorReceivePort.close();
  });

  if (resultDecoder == null) {
    receivePort.listen((d) => controller.add(d));
  } else {
    receivePort.listen((d) => controller.add(resultDecoder(d)));
  }

  return controller.stream;
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
