import 'package:go/go.dart';

int twice(int a) => a * 2;

main() async {
  print(await goMany(twice, 5, 20));
}