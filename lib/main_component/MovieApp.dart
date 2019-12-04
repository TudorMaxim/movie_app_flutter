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

  getMoviesOnline() async {
    List <Movie> movies = await movieService.getAll();
    movies.sort((x, y) => (y.priority - x.priority).toInt());
    setState(() {
      this.movies = movies;
      this.connected = true;
    });
  }

  getMoviesOffline() async {
    var movies = await moviesRepository.getMovies();
    movies.sort((x, y) => (y.priority - x.priority).toInt());
    setState(() {
      this.movies = movies;
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
    int newId = await moviesRepository.addMovie(movie);
    List <Movie> movies = [];
    movies.addAll(this.movies);
    movie.setId(newId);
    movies.add(movie);
    movies.sort((x, y) => (y.priority - x.priority).toInt());
    print("Added new movie with id: " + movie.id.toString());
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
    await movieService.deleteMovie(movie.id);
    print("Delete movie with id: " + movie.id.toString());
    await moviesRepository.deleteMovie(movie.id);
    setState(() {
      this.movies = movies;
    });
  }

  updateMovie(Movie movie) async {
    List <Movie> movies = [];
    movies.addAll(this.movies);
    int index = -1;
    for (int i = 0; i < this.movies.length && index < 0; i++) {
      if (this.movies[i].id == movie.id) {
        index = i;
      }
    }
    movie.setId(movies[index].id);
    movies[index] = movie;
    movies.sort((x, y) => (y.priority - x.priority).toInt());

    print("Update movie with id: " + movie.id.toString());
    await moviesRepository.updateMovie(movie.id, movie);
    await movieService.updateMovie(movie);

    setState(() {
      this.movies = movies;
    });
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
    print("Details about movie with id: " + movie.id.toString());
    final updatedMovie = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => MovieDetailsWidget(movie)
        )
    );
    if (updatedMovie != null) { // it was an update
     this.updateMovie(updatedMovie);
    }
  }

  sync() async {
    await this.movieService.sync(this.movies);
  }

  refreshConnectionState() {
    Timer.periodic(
        new Duration(seconds: 5),
        (timer) async {
          bool connected = await checkConnection();
          if (connected != this.connected) {
            if (connected == true) {
              await sync();
            }
            setState(() {
              this.connected = connected;
            });
          }
        }
    );
  }

  @override
  void initState() {
    super.initState();
    refreshConnectionState();
    if (this.movies.isEmpty && this.firstLoad) {
      this.getMovies().then((obj) {
        print("Fetched movies count: " + this.movies.length.toString());
        setState(() {
          this.firstLoad = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBody = this.firstLoad ? loading() : moviesListView();
    String subTitle  = this.connected ? "" : "You are offline!";
    return Scaffold(
        appBar: AppBar(
          title: Text('Your wish list'),
          centerTitle: true,
          bottom: PreferredSize(
            child: Text(subTitle, style: TextStyle(color: Colors.red)),
            preferredSize: null),
        ),
        body: appBody,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => this.goToAddForm(context)
        )
    );
  }

  loading() {
    return Center(
      child: Text("Loading...", style: TextStyle(fontSize: 24)),
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