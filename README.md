# go

Simplest API to multi process.

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