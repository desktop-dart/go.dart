import 'dart:async';
import 'package:go/go.dart';

Stream<int> fib(int n) async* {
  int a = 0, b = 1;

  while ((a + b) < n) {
    int newNum = a + b;
    a = b;
    b = newNum;
    yield newNum;
  }
}

main() async {
  final Stream<int> fs = await stream(fib, 50);
  await for (int f in fs) {
    print('Result from remote $f');
  }

  final StreamTask fibTask = remoteStream(fib);
  await for (int f in await fibTask(50)) {
    print('Result from remote $f');
  }
}
