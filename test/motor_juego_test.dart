import 'package:flutter_test/flutter_test.dart';
import 'package:momias_guanajuato/logica/personaje.dart';
import 'package:momias_guanajuato/logica/calaverita.dart';
import 'package:momias_guanajuato/logica/motor_juego.dart';
import 'package:momias_guanajuato/logica/momia.dart';
import 'package:momias_guanajuato/logica/rectangulo.dart';
import 'package:momias_guanajuato/logica/estado_juego.dart';

void main() {
  test('recolectar una calaverita suma puntos y la marca como recolectada', () {
    final personaje = Personaje(x: 100, y: 100);
    final calaverita = Calaverita(x: 105, y: 105);
    final puntos = MotorJuego.recolectarSiCorresponde(personaje, [calaverita]);
    expect(puntos, 50);
    expect(calaverita.recolectada, true);
  });

  test('una calaverita ya recolectada no vuelve a sumar puntos', () {
    final personaje = Personaje(x: 100, y: 100);
    final calaverita = Calaverita(x: 105, y: 105)..recolectada = true;
    final puntos = MotorJuego.recolectarSiCorresponde(personaje, [calaverita]);
    expect(puntos, 0);
  });

  test('al chocar lateralmente con una momia se pierde una vida y el personaje regresa al inicio', () {
    final personaje = Personaje(x: 95, y: 100);
    final momia = Momia(x: 100, y: 100, limiteIzquierdo: 100, limiteDerecho: 200, velocidadX: 0);
    final motor = MotorJuego(
      personaje: personaje,
      plataformas: const [Rectangulo(x: 0, y: 300, ancho: 1000, alto: 20)],
      momias: [momia],
      calaveritas: const [],
      posicionMeta: 500,
      anchoNivel: 1000,
    );

    motor.mover(0);

    expect(motor.vidas, 2);
    expect(personaje.x, 95); // regreso a la posicion inicial
  });

  test('perder la ultima vida cambia el estado a perdido', () {
    final personaje = Personaje(x: 95, y: 100);
    final momia = Momia(x: 100, y: 100, limiteIzquierdo: 100, limiteDerecho: 200, velocidadX: 0);
    final motor = MotorJuego(
      personaje: personaje,
      plataformas: const [Rectangulo(x: 0, y: 300, ancho: 1000, alto: 20)],
      momias: [momia],
      calaveritas: const [],
      posicionMeta: 500,
      anchoNivel: 1000,
    )..vidas = 1;

    motor.mover(0);

    expect(motor.estado, EstadoJuego.perdido);
  });

  test('llegar a la meta cambia el estado a ganado', () {
    final personaje = Personaje(x: 495, y: 268);
    final motor = MotorJuego(
      personaje: personaje,
      plataformas: const [Rectangulo(x: 0, y: 300, ancho: 1000, alto: 20)],
      momias: const [],
      calaveritas: const [],
      posicionMeta: 500,
      anchoNivel: 1000,
    );

    motor.mover(10); // 495 + 10 = 505, ya paso la meta en 500

    expect(motor.estado, EstadoJuego.ganado);
  });
}
