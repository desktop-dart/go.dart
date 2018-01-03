import 'package:go/go.dart';

int twice(int a) => a * 2;

main() async {
  final Herd<int, int> many = await herd(twice, 5);
  print(await many.execSame(5));
  print(await many.exec([10, 11, 12, 13, 14]));
  await many.shutdown();
}
