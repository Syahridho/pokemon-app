import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonDetailScreen extends StatefulWidget {
  final String pokemonUrl;

  const PokemonDetailScreen({super.key, required this.pokemonUrl});

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic>? pokemonData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemonDetails();
  }

  Future<void> fetchPokemonDetails() async {
    final response = await http.get(Uri.parse(widget.pokemonUrl));

    if (response.statusCode == 200) {
      setState(() {
        pokemonData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Detail'),
        backgroundColor: Colors.redAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      pokemonData!['name'].toString().toUpperCase(),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Image.network(
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/${pokemonData!['id']}.gif',
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard('Types', pokemonData!['types']),
                    _buildDetailCard('Abilities', pokemonData!['abilities']),
                    _buildDetailCard('Stats', pokemonData!['stats']),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailCard(String title, List<dynamic> data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.lightBlueAccent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...data.map<Widget>((item) {
              String displayValue = '';
              if (title == 'Types') {
                displayValue = item['type']['name'].toString().capitalize();
              } else if (title == 'Abilities') {
                displayValue = item['ability']['name'].toString().capitalize();
              } else if (title == 'Stats') {
                displayValue =
                    '${item['stat']['name'].toString().capitalize()}: ${item['base_stat']}';
              }
              return ListTile(
                title: Text(displayValue),
                tileColor: Colors.white.withOpacity(0.5),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}
