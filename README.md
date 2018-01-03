# go

[![Pub](https://img.shields.io/pub/v/go.svg)](https://pub.dartlang.org/packages/go)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/jaguar_dart/jaguar)

Seamlessly launch isolates to perform side jobs.

# Parallelize a task

```dart
import 'package:go/go.dart';

int twice(int a) => a * 2;

main() async {
  print(await go(twice, 5));
}
```

# Convert a task to remote task

```dart
import 'package:go/go.dart';

int twice(int a) => a * 2;

main() async {
  Task twiceTask = remoteTask(twice);
  print(await twiceTask(5));
}
```

# Parallel map of Iterable

```dart
import 'package:go/go.dart';

int twice(int a) => a * 2;

main() async {
  print(await goMap(twice, new List.generate(10, (int d) => d + 1)));
}
```

# Same task many times

Executes same task many times with same parameters.

```dart
int twice(int a) => a * 2;

main() async {
  print(await goMany(twice, 5, 20));
}
```

# Herd a group

```dart
int twice(int a) => a * 2;

main() async {
  final Herd<int, int> many = await herd(twice, 5);
  print(await many.execSame(5));
  print(await many.exec([10, 11, 12, 13, 14]));
  await many.shutdown();
}
```