import 'package:movie_app_flutter/model/Movie.dart';

class Repository {
  List <Movie> movies = [];
  int cnt = 10;

  Repository() {
    this._insertDummyMovies();
  }

  _insertDummyMovies() {
    for (int i = 0; i < cnt; i++) {
      this.addMovie(new Movie('${i + 1}', 'Movie ${i + 1}', 'Action', 'Movie', 3));
    }
  }

  getMovies() {
    return movies;
  }

  addMovie(movie) {
    movies.add(movie);
    movies.sort((a, b) => b.priority.compareTo(a.priority));
  }
  
  deleteMovie(id) {
    Movie movie = movies.where((movie) => movie.id == id).toList()[0];
    movies.remove(movie);
  }

  updateMovie(id, newMovie) {
    Movie oldMovie = movies.where((movie) => movie.id == id).toList()[0];
    movies.remove(oldMovie);
    movies.add(newMovie);
    movies.sort((a, b) => b.priority.compareTo(a.priority));
  }
}