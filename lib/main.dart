import 'package:flutter/material.dart';
import 'package:pokemon/list.dart';

void main() {
  runApp(const MyApp());
}

// penggunaan StatelessWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PokemonListScreen(),
    );
  }
}
