import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:movie_app_flutter/model/Movie.dart';

class MovieService {
  String url = 'http://10.0.2.2:3000';

   getAll() async {
    var response = await http.get('$url/movies', headers: {
      HttpHeaders.contentTypeHeader: 'application/json'
    });
    List <Movie> movies = [];
    if (response != null) {
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        body['movies'].forEach((movie) => movies.add(Movie.fromMap(movie)));
      }
    }
    return movies;
  }
  
  createMovie(Movie movie) async {
     var response = await http.post('$url/movies',
       headers: {
         HttpHeaders.contentTypeHeader: 'application/json'
       },
       body: json.encode(movie.toMap())
     );
     if (response != null && response.statusCode == 200) {
       return true;
     }
     return false;
  }

  createMoviesBatch(List <Movie> movies) async {
    var moviesJson =  movies.map((Movie movie) => movie.toMap());
    var response = await http.post('$url/movies/batch',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: json.encode(Movie.toJsonList(moviesJson))
    );
    if (response != null && response.statusCode == 200) {
      return true;
    }
    return false;
  }

  deleteMovie(int movieId) async {
     String id = movieId.toString();
     var response = await http.delete('$url/movies/$id');
     if (response != null && response.statusCode == 200) {
       return true;
     }
     return false;
  }

  updateMovie(Movie movie) async {
     String id = movie.id.toString();
     var response = await http.patch('$url/movies/$id',
         headers: {
           HttpHeaders.contentTypeHeader: 'application/json'
         },
         body: json.encode(movie.toMap())
     );
     if (response != null && response.statusCode == 200) {
       return true;
     }
     return false;
  }
}