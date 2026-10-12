import 'package:flutter/material.dart';
import 'presentation/juego_screen.dart';

void main() => runApp(const MomiasApp());

class MomiasApp extends StatelessWidget {
  const MomiasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momias de Guanajuato',
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      home: const JuegoScreen(),
    );
  }
}
