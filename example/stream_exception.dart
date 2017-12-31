import 'dart:async';
import 'package:go/go.dart';

Stream<int> fib(int n) async* {
  int a = 0, b = 1;

  while ((a + b) < n) {
    int newNum = a + b;
    a = b;
    b = newNum;

    if (b > 21) throw new Exception('Oppsy doopsy!');

    yield newNum;
  }
}

main() async {
  final Stream<int> fs = await stream(fib, 50);
  try {
    await for (int f in fs) {
      print('Result from remote $f');
    }
  } catch (e) {
    print(e);
  }

  print('Finished!');
}
