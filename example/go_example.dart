import 'package:go/go.dart';

int twice(int a) => a * 2;

main() async {
  print(await go(twice, 5));
  Task twiceTask = remoteTask(twice);
  print(await twiceTask(5));
}
