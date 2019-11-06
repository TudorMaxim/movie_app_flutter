import 'package:flutter/material.dart';
import 'package:movie_app_flutter/main_component/MovieWidget.dart';
import 'package:movie_app_flutter/model/Movie.dart';
import 'package:movie_app_flutter/repository/Repository.dart';


class MovieList extends StatefulWidget {
  final Repository moviesRepository;

  MovieList(this.moviesRepository);

  @override
  createState() => new MovieListState(moviesRepository);
}

class MovieListState extends State<MovieList> {
  Repository moviesRepository;

  MovieListState(this.moviesRepository);

  void deleteMovie(Movie movie) {
    setState(() {
      moviesRepository.deleteMovie(movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    var movies = moviesRepository.getMovies();
    return new ListView.builder(
        itemBuilder: (context, index) {
          if (index < moviesRepository.getMovies().length) {
            var movie = movies[index];
            return Dismissible(
              key: Key(movie.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => this.deleteMovie(movie),
              child: MovieWidget(movie, moviesRepository),
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