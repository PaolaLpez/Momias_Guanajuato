import 'rectangulo.dart';

class Momia {
  double x;
  final double y;
  final double ancho = 32;
  final double alto = 32;
  double velocidadX;
  final double limiteIzquierdo;
  final double limiteDerecho;
  bool derrotada = false;

  Momia({
    required this.x,
    required this.y,
    required this.limiteIzquierdo,
    required this.limiteDerecho,
    this.velocidadX = 2,
  });

  Rectangulo get rectangulo => Rectangulo(x: x, y: y, ancho: ancho, alto: alto);

  void patrullar() {
    if (derrotada) return;
    x += velocidadX;
    if (x <= limiteIzquierdo) {
      x = limiteIzquierdo;
      velocidadX = velocidadX.abs();
    } else if (x + ancho >= limiteDerecho) {
      x = limiteDerecho - ancho;
      velocidadX = -velocidadX.abs();
    }
  }
}
