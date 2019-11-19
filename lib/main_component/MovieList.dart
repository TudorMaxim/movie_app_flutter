import 'package:flutter/material.dart';
import 'package:movie_app_flutter/main_component/MovieWidget.dart';
import 'package:movie_app_flutter/model/Movie.dart';
import 'package:movie_app_flutter/repository/DbRepository.dart';

class MovieList extends StatefulWidget {
  MovieList();
  @override
  createState() => new MovieListState();
}

class MovieListState extends State<MovieList> {
  DbRepository moviesRepository = DbRepository();
  List <Movie> movies;

  void deleteMovie(Movie movie) async {
    await moviesRepository.deleteMovie(movie.id);
    await getMovies();
  }

  getMovies() async {
    await moviesRepository.init();
    var movies = await moviesRepository.getMovies();
    if (contentChanged(movies)) {
      setState(() {
        this.movies = movies;
      });
    }
  }

  contentChanged(List <Movie> moviesDb) {
    if (this.movies.length != moviesDb.length) {
      return true;
    }
    for (int i = 0; i < this.movies.length; i++) {
      if (!this.movies[i].equals(moviesDb[i])) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (this.movies == null) {
      this.movies = List<Movie>();
    }
    getMovies();
    return new ListView.builder(
        itemBuilder: (context, index) {
          if (index < this.movies.length) {
            var movie = this.movies[index];
            return Dismissible(
              key: Key(movie.id.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => this.deleteMovie(movie),
              child: MovieWidget(movie),
              background: Container(
                color: Colors.red,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text('Delete', style: TextStyle(fontSize: 24, color: Colors.white))
                  ),
                ),
              ),
            );
          }
          return null;
        }
    );
  }
}