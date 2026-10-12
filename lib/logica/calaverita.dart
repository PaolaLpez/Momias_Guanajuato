import 'rectangulo.dart';

class Calaverita {
  final double x, y;
  final double ancho = 20, alto = 20;
  bool recolectada = false;

  Calaverita({required this.x, required this.y});

  Rectangulo get rectangulo => Rectangulo(x: x, y: y, ancho: ancho, alto: alto);
}
