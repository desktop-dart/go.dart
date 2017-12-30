import 'package:go/go.dart';

int twice(int a) => a * 2;

main() async {
  print(await goMap(twice, new List.generate(10, (int d) => d + 1)));
}
