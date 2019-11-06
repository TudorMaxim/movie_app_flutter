
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app_flutter/model/Movie.dart';
import 'package:movie_app_flutter/repository/Repository.dart';

class FormWidget extends StatefulWidget {
  final Movie movie;
  final Repository moviesRepository;
  FormWidget(this.movie, this.moviesRepository);

  @override
  FormWidgetState createState() {
    return FormWidgetState(this.movie, this.moviesRepository);
  }
}

class FormWidgetState extends State<FormWidget> {
  Repository moviesRepository;
  final Movie movie;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController genreController = new TextEditingController();
  TextEditingController typeController = new TextEditingController();
  double priority = 0;

  FormWidgetState(this.movie, this.moviesRepository);

  String validator(value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  void addMovie() {
    var name = nameController.text;
    var genre = genreController.text;
    var type = typeController.text;
    double priority = this.priority;
    var max = 0;
    for (var m in moviesRepository.getMovies()) {
      if (int.parse(m.id) > max) {
        max = int.parse(m.id);
      }
    }
    int id = 1 + max;
    var newMovie = new Movie(id.toString(), name, genre, type, priority);
    moviesRepository.addMovie(newMovie);
    Navigator.pop(context);
  }

  updateMovie() {
    var name = nameController.text;
    var genre = genreController.text;
    var type = typeController.text;
    var newMovie = new Movie(movie.id, name, genre, type, this.priority);
    moviesRepository.updateMovie(movie.id, newMovie);
    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  void submit() {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState.validate()) {
      if (movie == null) {
        addMovie();
      } else {
        updateMovie();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (nameController.text.isEmpty) {
      nameController.text = movie != null ? movie.name : '';
    }
    if (genreController.text.isEmpty) {
      genreController.text = movie != null ? movie.genre : '';
    }
    if (typeController.text.isEmpty) {
      typeController.text = movie != null ? movie.type : '';
    }
    if (this.priority == 0) {
      this.priority = movie != null ? movie.priority : 3.0;
    }

    return Form(
        key: _formKey,
        child: Container (
          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
          child:  Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: "Name"
                ),
                validator: (value) => this.validator(value),
              ),
              TextFormField(
                controller: typeController,
                decoration: InputDecoration(
                    hintText: "Type"
                ),
                validator: (value) => this.validator(value),
              ),
              TextFormField (
                controller: genreController,
                decoration: InputDecoration(
                    hintText: "Genre"
                ),
                validator: (value) => this.validator(value),
              ),
              RatingBar(
                  initialRating: this.priority,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  allowHalfRating: true,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) => setState(() => this.priority = rating)
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Align (
                    alignment: Alignment.center,
                    child: RaisedButton(
                        onPressed: () => submit(),
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text('Submit')
                    ),
                  )
              ),
            ],
          ),
        )
    );
  }
}