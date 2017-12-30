part of go.stream;

/// Parameters to execute [task] with the [_delegate]
class _DelegateParams<R, P> {
  /// Task to execute
  final StreamTask<R, P> task;

  /// Parameters to the [task]
  final P params;

  /// Send port used to communicate the isolate
  final SendPort port;

  _DelegateParams(this.task, this.params, this.port);
}

_delegate<R, P>(_DelegateParams<R, P> params) async {
  final Stream<R> result = await params.task(params.params);
  result.listen((R r) => params.port.send(r));
}
