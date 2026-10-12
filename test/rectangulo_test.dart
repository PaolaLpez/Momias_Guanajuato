import 'package:flutter_test/flutter_test.dart';
import 'package:momias_guanajuato/logica/rectangulo.dart';

void main() {
  test('dos rectangulos que se traslapan se detectan como interseccion', () {
    const a = Rectangulo(x: 0, y: 0, ancho: 10, alto: 10);
    const b = Rectangulo(x: 5, y: 5, ancho: 10, alto: 10);
    expect(a.intersectaCon(b), true);
  });

  test('dos rectangulos separados no se intersectan', () {
    const a = Rectangulo(x: 0, y: 0, ancho: 10, alto: 10);
    const b = Rectangulo(x: 20, y: 20, ancho: 10, alto: 10);
    expect(a.intersectaCon(b), false);
  });
}
