part of go.herd;

class _HerdImpl<R, P> implements Herd<R, P> {
  final int count;

  final List<_Thread> _thread;

  final Encoder<P> encoder;

  final Decoder<R> decoder;

  _HerdImpl(this.count, this._thread, {this.encoder, this.decoder});

  bool _executing = false;

  bool _shutdown = false;

  Future<List<R>> exec(List<P> params) async {
    if (_shutdown) throw new Exception('Already shutdown!');

    if (_executing) {
      await new Future.delayed(new Duration(milliseconds: 500));
    }

    _executing = true;

    for (int i = 0; i < count; i++) {
      final sendParam = encoder != null ? encoder(params[i]) : params[i];
      _thread[i].send(sendParam);
    }

    final futures = <Future<R>>[];

    for (int i = 0; i < count; i++) {
      if (decoder == null) {
        futures.add(_thread[i].receive);
      } else {
        futures.add(_thread[i].receive.then((v) => decoder(v)));
      }
    }

    final List<R> ret = await Future.wait(futures);

    _executing = false; // TODO handle exceptions

    return ret;
  }

  Future<List<R>> execSame(P params) async {
    if (_shutdown) throw new Exception('Already shutdown!');

    final sendParam = encoder != null ? encoder(params) : params;

    if (_executing) {
      await new Future.delayed(new Duration(milliseconds: 500));
    }

    _executing = true;

    for (int i = 0; i < count; i++) {
      _thread[i].send(sendParam);
    }

    final futures = <Future<R>>[];

    for (int i = 0; i < count; i++) {
      if (decoder == null) {
        futures.add(_thread[i].receive);
      } else {
        futures.add(_thread[i].receive.then((v) => decoder(v)));
      }
    }

    final List<R> ret = await Future.wait(futures);

    _executing = false; // TODO handle exceptions

    return ret;
  }

  Future shutdown() async {
    _shutdown = true;
    for (int i = 0; i < count; i++) {
      await _thread[i].shutdown();
    }
  }
}

class _Thread<R, P> {
  final Isolate _isolate;

  final StreamQueue<R> _rxStream;

  final SendPort _sendPort;

  bool _shutdown = false;

  // TODO track exception!
  _Thread(this._isolate, this._rxStream, this._sendPort);

  void send(P param) {
    if (_shutdown) throw new Exception('Already shutdown!');
    _sendPort.send(param);
  }

  Future<R> get receive {
    if (_shutdown) throw new Exception('Already shutdown!');
    return _rxStream.next;
  }

  Future shutdown() async {
    _shutdown = true;
    _isolate.kill();
    await _rxStream.cancel(immediate: true);
  }
}
