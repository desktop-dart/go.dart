part of go.herd;

/// Parameters to execute [task] with the [_delegate]
class _DelegateInfo<R, P> {
  /// Task to execute
  final Task<R, P> task;

  /// Send port used to communicate the isolate
  final SendPort port;

  final Decoder<P> paramDecoder;

  final Encoder<R> resultEncoder;

  _DelegateInfo(this.task, this.port, {this.paramDecoder, this.resultEncoder});

  static _DelegateInfo<R, P> fromMap<R, P>(Map<String, dynamic> map) {
    return new _DelegateInfo<R, P>(map['task'], map['port'],
        paramDecoder: map['paramDecoder'], resultEncoder: map['resultEncoder']);
  }

  Map<String, dynamic> get toMap => {
        'task': task,
        'port': port,
        'paramDecoder': paramDecoder,
        'resultEncoder': resultEncoder
      };
}

_delegate<R, P>(Map map) async {
  final info = _DelegateInfo.fromMap<R, P>(map);

  final rxPort = new ReceivePort();

  info.port.send(rxPort.sendPort);

  final Encoder<R> encoder = info.resultEncoder;

  rxPort.listen((p) async {
    if (info.paramDecoder != null) p = info.paramDecoder(p);
    final R result = await info.task(p);
    info.port.send(encoder == null ? result : encoder(result));
  });
}
