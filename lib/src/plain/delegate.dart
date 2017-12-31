part of go;

typedef Map Encoder<T>(T param);

typedef T Decoder<T>(Map map);

/// Parameters to execute [task] with the [_delegate]
class _DelegateParams<R, P> {
  /// Task to execute
  final Task<R, P> task;

  /// Parameters to the [task]
  final P params;

  /// Send port used to communicate the isolate
  final SendPort port;

  final Encoder<P> paramEncoder;

  final Decoder<P> paramDecoder;

  final Encoder<R> resultEncoder;

  final Decoder<R> resultDecoder;

  _DelegateParams(this.task, this.params, this.port,
      {this.paramEncoder,
      this.paramDecoder,
      this.resultEncoder,
      this.resultDecoder});

  static _DelegateParams<R, P> fromMap<R, P>(Map<String, dynamic> map) {
    final Decoder<P> paramDecoder = map['paramDecoder'];
    final rawParam = map['params'];
    final P param = paramDecoder == null ? rawParam : paramDecoder(rawParam);
    return new _DelegateParams<R, P>(map['task'], param, map['port'],
        paramEncoder: map['paramEncoder'],
        paramDecoder: paramDecoder,
        resultEncoder: map['resultEncoder'],
        resultDecoder: map['resultDecoder']);
  }

  Map<String, dynamic> get toMap => {
        'task': task,
        'params': paramEncoder == null ? params : paramEncoder(params),
        'port': port,
        'paramEncoder': paramEncoder,
        'paramDecoder': paramDecoder,
        'resultEncoder': resultEncoder,
        'resultDecoder': resultDecoder,
      };
}

_delegate<R, P>(Map map) async {
  final params = _DelegateParams.fromMap<R, P>(map);
  final Encoder<R> encoder = params.resultEncoder;
  final R result = await params.task(params.params);
  params.port.send(encoder == null? result: encoder(result));
}
