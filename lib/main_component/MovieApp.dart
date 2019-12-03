import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app_flutter/details_component/MovieDetailsWidget.dart';
import 'package:movie_app_flutter/form_components/AddFormWidget.dart';
import 'package:movie_app_flutter/model/Movie.dart';
import 'package:movie_app_flutter/repository/DbRepository.dart';

class MovieApp extends StatefulWidget {
  MovieApp();
  @override
  createState() => new MovieAppState();
}

class MovieAppState extends State<MovieApp> {
  DbRepository moviesRepository = DbRepository();
  List <Movie> movies = [];
  bool firstLoad = true;

  getMovies() async {
    await moviesRepository.init();
    var movies = await moviesRepository.getMovies();
    movies.sort((x, y) => (y.priority - x.priority).toInt());
    setState(() {
      this.movies = movies;
      this.firstLoad = false;
    });
  }

  void deleteMovie(Movie movie) async {
    await moviesRepository.deleteMovie(movie.id);
    List <Movie> newState = [];
    newState.addAll(this.movies);
    int index = -1;
    for (int i = 0; i < this.movies.length && index < 0; i++) {
      if (this.movies[i].id == movie.id) {
        index = i;
      }
    }
    newState.removeAt(index);
    setState(() {
      this.movies = newState;
    });
  }

  void addMovie(Movie movie) async {
    await moviesRepository.addMovie(movie);
    List <Movie> newState = [];
    newState.addAll(this.movies);
    newState.add(movie);
    newState.sort((x, y) => (y.priority - x.priority).toInt());
    setState(() {
      this.movies = newState;
    });
  }

  void updateMovie(Movie movie) async {
    await moviesRepository.updateMovie(movie.id, movie);
    List <Movie> newState = [];
    newState.addAll(this.movies);
    int index = -1;
    for (int i = 0; i < this.movies.length && index < 0; i++) {
      if (this.movies[i].id == movie.id) {
        index = i;
      }
    }
    newState[index] = movie;
    newState.sort((x, y) => (y.priority - x.priority).toInt());
    setState(() {
      this.movies = newState;
    });
  }

  void goToAddForm(context) async {
    final newMovie = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddFormWidget()
        )
    );
    if (newMovie != null) {
      this.addMovie(newMovie);
    }
  }

  void goToDetails(context, Movie movie) async {
    final updatedMovie = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => MovieDetailsWidget(movie)
        )
    );
    print(updatedMovie);
    if (updatedMovie != null) { // it was an update
     this.updateMovie(updatedMovie);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.movies.isEmpty && this.firstLoad) {
      print("FETCH MOVIES FROM DB!");
      getMovies();
    }
    return Scaffold(
        appBar: AppBar(
            title: Text('Your wish list')
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
            return this.dismissibleMovie(movie);
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