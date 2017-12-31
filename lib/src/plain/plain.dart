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
Future<R> go<R, P>(Task<R, P> task, P param,
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

  final errorReceivePort = new ReceivePort();
  isolate.addErrorListener(errorReceivePort.sendPort);
  dynamic error;
  errorReceivePort.listen((e) {
    error = e;
    receivePort.close();
  });

  try {
    final rawResult = await receivePort.first;
    isolate.kill();
    errorReceivePort.close();
    final R result =
        resultDecoder == null ? rawResult : resultDecoder(rawResult);
    return result;
  } on StateError catch (_) {
    receivePort.close();
    errorReceivePort.close();
    if (error != null) throw error;
    rethrow;
  }
}

class _ExceptionWrap {
  dynamic exception;

  _ExceptionWrap(this.exception);
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
