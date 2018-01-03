library go.herd;

import 'dart:async';
import 'dart:isolate';
import 'package:async/async.dart';

import '../plain/plain.dart';

part 'delegate.dart';
part 'herd_impl.dart';

/// Encapsulates a herd and exposes an interface to control it. Use [herd] to
/// create a new [Herd].
abstract class Herd<R, P> {
  /// Number of parallel tasks
  int get count;

  /// Executes all the individuals of the herd with different parameters [params]
  /// and return result.
  FutureOr<List<R>> exec(List<P> params);

  /// Executes all the individuals of the herd with same parameters [params] and
  /// return result.
  FutureOr<List<R>> execSame(P params);

  /// Shuts down the herd.
  FutureOr shutdown();
}

/// Creates a [Herd] to request processing on demand with [count] individuals.
///
/// Example:
///
///     int twice(int a) => a * 2;
///
///     main() async {
///       final Herd<int, int> many = await herd(twice, 5);
///       print(await many.execSame(5));
///       await many.shutdown();
///     }
Future<Herd> herd<R, P>(Task<R, P> task, int count,
    {Encoder<P> paramEncoder,
    Decoder<P> paramDecoder,
    Encoder<R> resultEncoder,
    Decoder<R> resultDecoder}) async {
  final threads = new List<_Thread>(count);

  for (int i = 0; i < count; i++) {
    final receivePort = new ReceivePort();
    final info = new _DelegateInfo<R, P>(task, receivePort.sendPort,
        paramDecoder: paramDecoder, resultEncoder: resultEncoder);
    final isolate = await Isolate.spawn(_delegate, info.toMap);
    final rxStream = new StreamQueue(receivePort);
    final SendPort sendPort = await rxStream.next;
    final newThread = new _Thread(isolate, rxStream, sendPort);
    threads[i] = newThread;
  }

  return new _HerdImpl<R, P>(count, threads,
      encoder: paramEncoder, decoder: resultDecoder);
}
