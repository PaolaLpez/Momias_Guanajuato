import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logica/motor_juego.dart';
import '../logica/personaje.dart';
import '../logica/momia.dart';
import '../logica/calaverita.dart';
import '../logica/rectangulo.dart';
import '../logica/estado_juego.dart';

class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> with SingleTickerProviderStateMixin {
  late MotorJuego _motor;
  Timer? _bucle;
  double _direccion = 0;

  // Control de teclado en PC
  final FocusNode _focusNode = FocusNode();
  bool _teclaIzquierda = false;
  bool _teclaDerecha = false;

  // Animaciones y efectos cosméticos
  late AnimationController _animController;
  int _vidasPrevias = 3;
  bool _golpeReciente = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _iniciarNivel();
    _iniciarBucle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _iniciarNivel() {
    _motor = MotorJuego(
      personaje: Personaje(x: 20, y: 100),
      plataformas: const [
        Rectangulo(x: 0, y: 300, ancho: 2000, alto: 40),
        Rectangulo(x: 300, y: 220, ancho: 120, alto: 20),
        Rectangulo(x: 550, y: 160, ancho: 120, alto: 20),
      ],
      momias: [
        Momia(x: 320, y: 268, limiteIzquierdo: 300, limiteDerecho: 420),
        Momia(x: 900, y: 268, limiteIzquierdo: 850, limiteDerecho: 1100),
      ],
      calaveritas: [
        Calaverita(x: 360, y: 180),
        Calaverita(x: 600, y: 120),
        Calaverita(x: 1200, y: 260),
      ],
      posicionMeta: 1900,
      anchoNivel: 2000,
    );
    _vidasPrevias = _motor.vidas;
    _golpeReciente = false;
  }

  void _iniciarBucle() {
    _bucle = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        _motor.mover(_direccion * 4);
        if (_motor.vidas < _vidasPrevias) {
          _vidasPrevias = _motor.vidas;
          _activarEfectoGolpe();
        }
      });

      if (_motor.estado != EstadoJuego.jugando) {
        _bucle?.cancel();
        _mostrarResultado();
      }
    });
  }

  void _activarEfectoGolpe() {
    _golpeReciente = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _golpeReciente = false);
    });
  }

  void _actualizarDireccion() {
    if (_teclaIzquierda && !_teclaDerecha) {
      _direccion = -1;
    } else if (_teclaDerecha && !_teclaIzquierda) {
      _direccion = 1;
    } else {
      _direccion = 0;
    }
  }

  KeyEventResult _manejarTeclado(FocusNode node, KeyEvent event) {
    final esAbajo = event is KeyDownEvent || event is KeyRepeatEvent;
    final esArriba = event is KeyUpEvent;

    final esIzq = event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA;
    final esDer = event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD;
    final esSalto = event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.keyW;

    if (esIzq) {
      if (esAbajo) _teclaIzquierda = true;
      if (esArriba) _teclaIzquierda = false;
      _actualizarDireccion();
      return KeyEventResult.handled;
    } else if (esDer) {
      if (esAbajo) _teclaDerecha = true;
      if (esArriba) _teclaDerecha = false;
      _actualizarDireccion();
      return KeyEventResult.handled;
    } else if (esSalto) {
      if (event is KeyDownEvent) {
        _motor.saltar();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _bucle?.cancel();
    _animController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _mostrarResultado() {
    final gano = _motor.estado == EstadoJuego.ganado;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'resultado',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
        child: FadeTransition(
          opacity: anim1,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gano
                        ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
                        : [const Color(0xFFC2185B), const Color(0xFF4A148C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: gano ? const Color(0xFFFFD54F) : const Color(0xFFFF80AB),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gano ? '🎉 ¡VICTORIA! 💋' : '💀 ¡FIN DEL JUEGO! 🧟',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      gano
                          ? '¡Llegaste al legendario Callejón del Beso y burlaste a las momias!'
                          : 'Las momias de Guanajuato te alcanzaron en los callejones.',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💀 ', style: TextStyle(fontSize: 22)),
                          Text(
                            'Puntaje Final: ${_motor.puntaje}',
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 8,
                      ),
                      icon: const Icon(Icons.replay_rounded, size: 24),
                      label: const Text(
                        'JUGAR DE NUEVO',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(_iniciarNivel);
                        _iniciarBucle();
                        _focusNode.requestFocus();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const anchoVentana = 360.0;
    final camaraX = (_motor.personaje.x - anchoVentana / 2)
        .clamp(0.0, _motor.anchoNivel - anchoVentana);

    final progresoMeta = (_motor.personaje.x / _motor.posicionMeta).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF1A102F),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _manejarTeclado,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: Column(
              children: [
                // Barra superior de estado / HUD estilo Colonial & Neumórfico
                _construirHUD(progresoMeta),

                // Escenario del Juego (Mundo 2D con cámara móvil)
                Expanded(
                  child: ClipRect(
                    child: Stack(
                      children: [
                        // Fondo atmosférico colonial Guanajuato
                        _construirFondoGuanajuato(camaraX),

                        // Meta: Balcones del Callejón del Beso (x: 1900)
                        _construirCallejonDelBeso(camaraX),

                        // Plataformas (Cantera Rosa de Guanajuato)
                        ..._motor.plataformas.map((pl) => Positioned(
                              left: pl.x - camaraX,
                              top: pl.y,
                              child: _construirPlataforma(pl),
                            )),

                        // Calaveritas de Azúcar (Coleccionables)
                        ..._motor.calaveritas.where((c) => !c.recolectada).map((c) => Positioned(
                              left: c.x - camaraX,
                              top: c.y - (_animController.value * 6), // Levitan suavemente
                              child: _construirCalaverita(c),
                            )),

                        // Momias patrulleras (Enemigos)
                        ..._motor.momias.where((m) => !m.derrotada).map((m) => Positioned(
                              left: m.x - camaraX,
                              top: m.y,
                              child: _construirMomia(m),
                            )),

                        // Personaje Explorador (Jugador)
                        Positioned(
                          left: _motor.personaje.x - camaraX,
                          top: _motor.personaje.y,
                          child: _construirPersonaje(),
                        ),

                        // Flash rojo suave cuando recibe un golpe
                        if (_golpeReciente)
                          Positioned.fill(
                            child: Container(
                              color: Colors.red.withOpacity(0.35),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Controles inferiores táctiles con indicador de teclado PC
                _construirControlesInferiores(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HUD superior con Vidas, Puntaje y Barra de Progreso a la meta
  Widget _construirHUD(double progresoMeta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF24153B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(bottom: BorderSide(color: Color(0xFF4A2A70), width: 1.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Vidas representadas con corazones
              Row(
                children: [
                  const Text('VIDAS: ', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  ...List.generate(3, (index) {
                    final tieneVida = index < _motor.vidas;
                    return Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(
                        tieneVida ? Icons.favorite : Icons.favorite_border,
                        color: tieneVida ? const Color(0xFFFF1744) : Colors.white24,
                        size: 22,
                      ),
                    );
                  }),
                ],
              ),

              // Título con estilo temático
              const Row(
                children: [
                  Text('🏮 ', style: TextStyle(fontSize: 16)),
                  Text(
                    'GUANAJUATO',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Puntaje con calaverita dorada
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF381E57),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.6)),
                ),
                child: Row(
                  children: [
                    const Text('💀 ', style: TextStyle(fontSize: 13)),
                    Text(
                      '${_motor.puntaje} pts',
                      style: const TextStyle(
                        color: Color(0xFFFFD54F),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mini barra de distancia al Callejón del Beso
          Row(
            children: [
              const Text('🤠', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progresoMeta,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text('💋 Beso', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Fondo con atardecer de Guanajuato, siluetas coloniales y faroles
  Widget _construirFondoGuanajuato(double camaraX) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B0C2E), // Cielo nocturno colonial
              Color(0xFF4A1942), // Púrpura cantera
              Color(0xFF8C3A4F), // Rojizo atardecer
              Color(0xFFE07A5F), // Naranja colonial cálido
              Color(0xFFF4A261), // Luces de la cañada
            ],
            stops: [0.0, 0.35, 0.65, 0.85, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Luna colonial en lo alto
            Positioned(
              top: 30,
              right: 60,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF9C4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFF59D).withOpacity(0.5),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

            // Estrellas titilantes
            Positioned(top: 20, left: 40, child: _estrella(0.8)),
            Positioned(top: 60, left: 120, child: _estrella(0.5)),
            Positioned(top: 45, left: 240, child: _estrella(0.7)),
            Positioned(top: 80, right: 140, child: _estrella(0.6)),

            // Siluetas de casas coloniales y cúpulas en el fondo con efecto parallax
            Positioned(
              bottom: 80,
              left: -(camaraX * 0.25) % 600,
              right: -600,
              child: Row(
                children: List.generate(10, (i) => _siluetaCasaColonial(i)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estrella(double escala) {
    return Transform.scale(
      scale: escala,
      child: const Icon(Icons.star, color: Colors.white60, size: 10),
    );
  }

  Widget _siluetaCasaColonial(int index) {
    final alturas = [70.0, 95.0, 60.0, 110.0, 85.0];
    final altura = alturas[index % alturas.length];
    return Container(
      width: 55,
      height: altura,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF33163B).withOpacity(0.75),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          width: 8,
          height: 12,
          color: (index % 2 == 0) ? const Color(0xFFFFD54F).withOpacity(0.6) : Colors.transparent,
        ),
      ),
    );
  }

  // Meta del juego: El Callejón del Beso
  Widget _construirCallejonDelBeso(double camaraX) {
    return Positioned(
      left: 1850 - camaraX,
      top: 100,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('💋 ', style: TextStyle(fontSize: 16)),
                Text(
                  'CALLEJÓN DEL BESO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Balcones coloniales enfrentados
          Row(
            children: [
              _balconColonial(),
              const SizedBox(width: 8),
              const Text('🌹', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              _balconColonial(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balconColonial() {
    return Container(
      width: 38,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF880E4F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.wb_incandescent, color: Color(0xFFFFE082), size: 14),
          Container(
            height: 16,
            color: const Color(0xFF4A148C),
            alignment: Alignment.center,
            child: const Text('🌺', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // Plataformas con textura de cantera rosa colonial y relieve 3D
  Widget _construirPlataforma(Rectangulo pl) {
    return Container(
      width: pl.ancho,
      height: pl.alto,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF06292), // Resalte superior cantera
            Color(0xFFC2185B), // Tonalidad rosa colonial
            Color(0xFF880E4F), // Sombra inferior
          ],
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _TexturaAdoquinPainter(),
      ),
    );
  }

  // Calaverita con aura dorada de Día de Muertos
  Widget _construirCalaverita(Calaverita c) {
    return Container(
      width: c.ancho,
      height: c.alto,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('\u{1F480}', style: TextStyle(fontSize: 20)),
    );
  }

  // Momia de Guanajuato con ojos brillantes y aura sombría
  Widget _construirMomia(Momia m) {
    return Container(
      width: m.ancho,
      height: m.alto,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD7CCC8), Color(0xFF8D6E63)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4E342E), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('\u{1F9DF}', style: TextStyle(fontSize: 20)),
    );
  }

  // Explorador con sombrero y dynamic tilt
  Widget _construirPersonaje() {
    // Si camina hacia la izquierda o derecha, inclinación dinámica
    final rotacion = _direccion == -1 ? -0.08 : (_direccion == 1 ? 0.08 : 0.0);

    return Transform.rotate(
      angle: rotacion,
      child: Container(
        width: _motor.personaje.ancho,
        height: _motor.personaje.alto,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text('\u{1F920}', style: TextStyle(fontSize: 20)),
      ),
    );
  }

  // Controles inferiores con botones táctiles y guía de teclas PC
  Widget _construirControlesInferiores() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF201335),
        border: const Border(top: BorderSide(color: Color(0xFF3B1E61), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner indicador de teclado para computadora
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_outlined, color: Colors.white70, size: 16),
                SizedBox(width: 6),
                Text(
                  'Teclas PC:  [← / A] Izq   |   [→ / D] Der   |   [↑ / W / Espacio] Saltar',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Botones en pantalla
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botones de movimiento lateral
              Row(
                children: [
                  _boton(
                    icono: Icons.arrow_back_rounded,
                    label: 'IZQ',
                    color: const Color(0xFF3949AB),
                    alPresionar: () => _direccion = -1,
                    alSoltar: () => _direccion = 0,
                  ),
                  const SizedBox(width: 16),
                  _boton(
                    icono: Icons.arrow_forward_rounded,
                    label: 'DER',
                    color: const Color(0xFF3949AB),
                    alPresionar: () => _direccion = 1,
                    alSoltar: () => _direccion = 0,
                  ),
                ],
              ),

              // Botón de salto
              _boton(
                icono: Icons.arrow_upward_rounded,
                label: 'SALTAR',
                color: const Color(0xFFD81B60),
                tamano: 68,
                alPresionar: () => _motor.saltar(),
                alSoltar: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boton({
    required IconData icono,
    required String label,
    required Color color,
    required VoidCallback alPresionar,
    required VoidCallback alSoltar,
    double tamano = 60,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        alPresionar();
        _focusNode.requestFocus();
      },
      onTapUp: (_) => alSoltar(),
      onTapCancel: alSoltar,
      child: Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.9), color],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: Colors.white, size: tamano * 0.45),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pintor de textura estilo adoquín/cantera colonial
class _TexturaAdoquinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Líneas simulando bloques de piedra colonial
    const paso = 30.0;
    for (double x = paso; x < size.width; x += paso) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
