import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Movies(),
    );
  }
}

class Movies extends StatefulWidget {
  const Movies({
    super.key,
  });

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  final String baseUrl = 'https://api.themoviedb.org/3/movie/popular';
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  List movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (Dismissible(
              key: Key(movies[0]['id'].toString()),
              onDismissed: (direction) {
                setState(() {
                  movies.removeAt(0);
                });
              },
              child: Stack(
                children: [
                  Image.network('$imageBaseUrl${movies[0]['poster_path']}')
                ],
              ),
            )),
    );
  }

  Future<void> _fetchMovies() async {
    final apiKey = dotenv.env['TMDB_API_KEY'];
    final response = await http.get(Uri.parse('$baseUrl?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        movies = data['results'];
        isLoading = false;
      });
      if (kDebugMode) {
        print(movies);
      }
    } else {
      setState(() {
        isLoading = true;
      });
    }
  }
}
