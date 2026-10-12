import 'personaje.dart';
import 'rectangulo.dart';

class MotorFisica {
  static const double gravedad = 0.8;
  static const double impulsoSalto = -12;

  static void aplicarGravedad(Personaje personaje) {
    personaje.velocidadY += gravedad;
    personaje.y += personaje.velocidadY;
  }

  static void saltar(Personaje personaje) {
    if (personaje.enElSuelo) {
      personaje.velocidadY = impulsoSalto;
      personaje.enElSuelo = false;
    }
  }

  static void resolverColisionConPiso(
    Personaje personaje,
    List<Rectangulo> plataformas,
    double yAnterior,
  ) {
    personaje.enElSuelo = false;
    final pieAnterior = yAnterior + personaje.alto;
    for (final plataforma in plataformas) {
      final pieActual = personaje.y + personaje.alto;
      final cayendoSobreElla = personaje.velocidadY >= 0 &&
          (pieAnterior <= plataforma.y || yAnterior <= plataforma.y) &&
          pieActual >= plataforma.y &&
          personaje.x + personaje.ancho > plataforma.x &&
          personaje.x < plataforma.x + plataforma.ancho;
      if (cayendoSobreElla) {
        personaje.y = plataforma.y - personaje.alto;
        personaje.velocidadY = 0;
        personaje.enElSuelo = true;
      }
    }
  }

  static void moverHorizontal(Personaje personaje, double delta, double anchoNivel) {
    personaje.x += delta;
    if (personaje.x < 0) personaje.x = 0;
    if (personaje.x + personaje.ancho > anchoNivel) {
      personaje.x = anchoNivel - personaje.ancho;
    }
  }

  static bool haLlegadoALaMeta(Personaje personaje, double posicionMeta) {
    return personaje.x >= posicionMeta;
  }
}
