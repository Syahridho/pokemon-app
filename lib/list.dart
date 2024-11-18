import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokemon/detail.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemonList = [];
  List<dynamic> filteredList = [];
  bool isLoading = true;
  bool isSearching = false;
  int limit = 50;

  @override
  void initState() {
    super.initState();
    fetchPokemonList();
  }

  Future<void> fetchPokemonList() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit'));

    if (response.statusCode == 200) {
      List<dynamic> pokemons = json.decode(response.body)['results'];

      for (var pokemon in pokemons) {
        final pokemonId = pokemons.indexOf(pokemon) + 1;
        pokemon['sprite'] =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/$pokemonId.gif';
      }

      setState(() {
        pokemonList = pokemons;
        filteredList = pokemons;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }

  Future<void> filterPokemon(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredList = pokemonList;
      });
      return;
    }

    final filtered = pokemonList.where((pokemon) {
      final name = pokemon['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      await searchPokemonInAPI(query);
    } else {
      setState(() {
        filteredList = filtered;
      });
    }
  }

  Future<void> searchPokemonInAPI(String query) async {
    if (isSearching) return;

    setState(() {
      isSearching = true;
    });

    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$query'));

    if (response.statusCode == 200) {
      final pokemon = json.decode(response.body);
      final pokemonId = pokemon['id'];
      pokemon['sprite'] =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/$pokemonId.gif';

      setState(() {
        filteredList = [pokemon];
      });
    } else {
      setState(() {
        filteredList = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pokémon "${query}" not found.')),
      );
    }

    setState(() {
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: filterPokemon,
                    decoration: InputDecoration(
                      hintText: 'Search Pokémon...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final pokemon = filteredList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonDetailScreen(
                                  pokemonUrl: pokemon['url']),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.network(
                                  pokemon['sprite'] ?? '',
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey, // Gambar abu-abu
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  pokemon['name'].toString().toUpperCase(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 2; // 2 columns on mobile
    } else if (screenWidth < 1200) {
      return 6; // 6 columns on tablet
    } else {
      return 8; // 8 columns on desktop
    }
  }
}
