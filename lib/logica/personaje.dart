import 'rectangulo.dart';

class Personaje {
  double x;
  double y;
  double velocidadY = 0;
  final double ancho = 32;
  final double alto = 32;
  bool enElSuelo = false;

  Personaje({required this.x, required this.y});

  Rectangulo get rectangulo => Rectangulo(x: x, y: y, ancho: ancho, alto: alto);
}
