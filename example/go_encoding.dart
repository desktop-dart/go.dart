import 'package:go/go.dart';

class Number {
  int number;

  Number(this.number);

  static Number fromMap(Map map) => new Number(map['number']);

  static Map toMap(Number entity) => {
        'number': entity.number,
      };

  String toString() => number.toString();
}

Number twice(Number a) => new Number(a.number * 2);

main() async {
  print(await go<Number, Number>(twice, new Number(5),
      paramEncoder: Number.toMap,
      paramDecoder: Number.fromMap,
      resultEncoder: Number.toMap,
      resultDecoder: Number.fromMap));
}
