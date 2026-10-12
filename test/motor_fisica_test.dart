import 'package:flutter_test/flutter_test.dart';
import 'package:momias_guanajuato/logica/personaje.dart';
import 'package:momias_guanajuato/logica/motor_fisica.dart';
import 'package:momias_guanajuato/logica/rectangulo.dart';

void main() {
  test('aplicarGravedad aumenta la velocidad vertical y mueve al personaje hacia abajo', () {
    final personaje = Personaje(x: 0, y: 0);
    MotorFisica.aplicarGravedad(personaje);
    expect(personaje.velocidadY, MotorFisica.gravedad);
    expect(personaje.y, MotorFisica.gravedad);
  });

  test('saltar solo funciona si el personaje esta en el suelo', () {
    final personaje = Personaje(x: 0, y: 0)..enElSuelo = true;
    MotorFisica.saltar(personaje);
    expect(personaje.velocidadY, MotorFisica.impulsoSalto);
    expect(personaje.enElSuelo, false);
  });

  test('saltar no hace nada si el personaje ya esta en el aire', () {
    final personaje = Personaje(x: 0, y: 0)..enElSuelo = false;
    MotorFisica.saltar(personaje);
    expect(personaje.velocidadY, 0);
  });

  test('el personaje aterriza sobre una plataforma al caer sobre ella', () {
    final personaje = Personaje(x: 10, y: 90)..velocidadY = 5;
    const plataforma = Rectangulo(x: 0, y: 100, ancho: 100, alto: 20);
    MotorFisica.resolverColisionConPiso(personaje, [plataforma], 85);
    expect(personaje.enElSuelo, true);
    expect(personaje.y, 100 - personaje.alto);
    expect(personaje.velocidadY, 0);
  });

  test('el personaje no aterriza si todavia esta muy por encima de la plataforma', () {
    final personaje = Personaje(x: 10, y: 50)..velocidadY = 5;
    const plataforma = Rectangulo(x: 0, y: 100, ancho: 100, alto: 20);
    MotorFisica.resolverColisionConPiso(personaje, [plataforma], 45);
    expect(personaje.enElSuelo, false);
  });

  test('moverHorizontal desplaza al personaje segun el delta recibido', () {
    final personaje = Personaje(x: 50, y: 0);
    MotorFisica.moverHorizontal(personaje, 10, 1000);
    expect(personaje.x, 60);
  });

  test('moverHorizontal no deja salir al personaje por el borde izquierdo', () {
    final personaje = Personaje(x: 2, y: 0);
    MotorFisica.moverHorizontal(personaje, -10, 1000);
    expect(personaje.x, 0);
  });

  test('moverHorizontal no deja salir al personaje por el borde derecho', () {
    final personaje = Personaje(x: 990, y: 0);
    MotorFisica.moverHorizontal(personaje, 20, 1000);
    expect(personaje.x, 1000 - personaje.ancho);
  });

  test('haLlegadoALaMeta es verdadero cuando el personaje alcanza la posicion', () {
    final personaje = Personaje(x: 1900, y: 0);
    expect(MotorFisica.haLlegadoALaMeta(personaje, 1900), true);
  });

  test('haLlegadoALaMeta es falso si aun no llega', () {
    final personaje = Personaje(x: 500, y: 0);
    expect(MotorFisica.haLlegadoALaMeta(personaje, 1900), false);
  });
}
