import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app_flutter/details_component/MovieDetailsWidget.dart';
import 'package:movie_app_flutter/form_components/AddFormWidget.dart';
import 'package:movie_app_flutter/model/Movie.dart';
import 'package:movie_app_flutter/repository/DbRepository.dart';
import 'package:movie_app_flutter/service/MovieService.dart';
import 'package:movie_app_flutter/shared/sharedMethods.dart';

class MovieApp extends StatefulWidget {
  MovieApp();
  @override
  createState() => new MovieAppState();
}

class MovieAppState extends State<MovieApp> {
  DbRepository moviesRepository = DbRepository();
  MovieService movieService = MovieService();
  List <Movie> movies = [];
  bool firstLoad = true;
  bool connected = false;
  int onlineMaxId = 0;

  getMoviesOnline() async {
    List <Movie> movies = await movieService.getAll();
    movies.sort((x, y) => (y.priority - x.priority).toInt());
    setState(() {
      this.movies = movies;
      this.firstLoad = false;
      this.connected = true;
      this.onlineMaxId = movies.last.id;
    });
  }

  getMoviesOffline() async {
    var movies = await moviesRepository.getMovies();
    movies.sort((x, y) => (y.priority - x.priority).toInt());
    setState(() {
      this.movies = movies;
      this.firstLoad = false;
      this.connected = false;
    });
  }

  getMovies() async {
    await moviesRepository.init();
    bool connected = await checkConnection();
    if (connected) {
      await getMoviesOnline();
    } else {
      await getMoviesOffline();
    }
  }

  addMovieLocalDb(Movie movie) async {
    await moviesRepository.addMovie(movie);
    List <Movie> movies = [];
    movies.addAll(this.movies);
    movies.add(movie);
    movies.sort((x, y) => (y.priority - x.priority).toInt());
    return movies;
  }

  addMovieOffline(Movie movie) async {
    List <Movie> movies = await addMovieLocalDb(movie);
    setState(() {
      this.movies = movies;
      this.connected = false;
    });
  }

  addMovieOnline(Movie movie) async {
    bool success = await movieService.createMovie(movie);
    if (success) {
      List <Movie> movies = await addMovieLocalDb(movie);
      setState(() {
        this.movies = movies;
        this.connected = true;
      });
    } else {
      showAlertDialog(context, "An error occured while adding the movie");
    }
  }

  addMovie(Movie movie) async {
    bool connected = await checkConnection();
    if (connected) {
      await addMovieOnline(movie);
    } else {
      await addMovieOffline(movie);
    }
  }

  deleteDb(Movie movie) async {
    await moviesRepository.deleteMovie(movie.id);
    List <Movie> movies = [];
    movies.addAll(this.movies);
    int index = -1;
    for (int i = 0; i < this.movies.length && index < 0; i++) {
      if (this.movies[i].id == movie.id) {
        index = i;
      }
    }
    movies.removeAt(index);
    setState(() {
      this.movies = movies;
    });
  }

  deleteMovie(Movie movie) async {
    List <Movie> movies = [];
    movies.addAll(this.movies);
    int index = -1;
    for (int i = 0; i < this.movies.length && index < 0; i++) {
      if (this.movies[i].id == movie.id) {
        index = i;
      }
    }
    movies.removeAt(index);
    bool code = await movieService.deleteMovie(movie.id);
    print("DELETE CODE: " + code.toString());
    await moviesRepository.deleteMovie(movie.id);
    setState(() {
      this.movies = movies;
    });
  }

  updateMovie(Movie movie) async {
    await moviesRepository.updateMovie(movie.id, movie);
    await movieService.updateMovie(movie);
    List <Movie> movies = [];
    movies.addAll(this.movies);
    int index = -1;
    for (int i = 0; i < this.movies.length && index < 0; i++) {
      if (this.movies[i].id == movie.id) {
        index = i;
      }
    }
    movies[index] = movie;
    movies.sort((x, y) => (y.priority - x.priority).toInt());
    setState(() {
      this.movies = movies;
    });
  }

  synchronize() async {
    List <Movie> moviesAddedOffline = await moviesRepository.getMoviesInsertedOffline(this.onlineMaxId);
    if (moviesAddedOffline.length > 0) {
      await movieService.createMoviesBatch(moviesAddedOffline);
    }
  }

  goToAddForm(context) async {
    final newMovie = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddFormWidget()
        )
    );
    if (newMovie != null) {
      this.addMovie(newMovie);
    }
  }

  goToDetails(context, Movie movie) async {
    final updatedMovie = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => MovieDetailsWidget(movie)
        )
    );
    if (updatedMovie != null) { // it was an update
     this.updateMovie(updatedMovie);
    }
  }

  refreshConnectionState() {
    Timer.periodic(
        new Duration(seconds: 5),
        (timer) async {
          bool connected = await checkConnection();
          if (connected != this.connected) {
            setState(() {
              this.connected = connected;
            });
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    refreshConnectionState();
    String subTitle  = "";
    if (!this.connected) {
      subTitle = "You are offline";
    }

    print(this.connected);
    if (this.movies.isEmpty && this.firstLoad) {
      this.getMovies();
    }
    return Scaffold(
        appBar: AppBar(
            title: Text('Your wish list'),
            centerTitle: true,
            bottom: PreferredSize(
                child: Text(subTitle, style: TextStyle(color: Colors.red)),
                preferredSize: null),
        ),
        body: moviesListView(),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => this.goToAddForm(context)
        )
    );
  }

  ListView moviesListView() {
    return new ListView.builder(
        itemBuilder: (context, index) {
          if (index < this.movies.length) {
            var movie = this.movies[index];
            if (this.connected) {
              return dismissibleMovie(movie);
            }
            return movieListTile(movie);
          }
          return null;
        }
    );
  }

  Dismissible dismissibleMovie(Movie movie) {
    return Dismissible(
      key: Key(movie.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => this.deleteMovie(movie),
      child: movieListTile(movie),
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

  ListTile movieListTile(movie) {
    return  ListTile (
        contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
        title: Text(movie.name, style: TextStyle(fontSize: 24)),
        subtitle: RatingBarIndicator(
          rating: movie.priority,
          direction: Axis.horizontal,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
        ),
        onTap: () => goToDetails(context, movie)
    );
  }
}