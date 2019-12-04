
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app_flutter/model/Movie.dart';
import 'package:movie_app_flutter/repository/DbRepository.dart';
import 'package:movie_app_flutter/shared/sharedMethods.dart';

class FormWidget extends StatefulWidget {
  final Movie movie;
  FormWidget(this.movie);

  @override
  FormWidgetState createState() {
    return FormWidgetState(this.movie);
  }
}

class FormWidgetState extends State<FormWidget> {
  final Movie movie;
  final DbRepository moviesRepository = DbRepository();

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController genreController = new TextEditingController();
  TextEditingController typeController = new TextEditingController();
  double priority = 0;

  FormWidgetState(this.movie);

  String validator(value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  void addMovie() async {
    var name = nameController.text;
    var genre = genreController.text;
    var type = typeController.text;
    double priority = this.priority;

    var newMovie = Movie.fromMap({
      'id': null,
      'name': name,
      'genre': genre,
      'type': type,
      'priority': priority
    });
    Navigator.pop(context, newMovie);
  }

  updateMovie() async {
    var name = nameController.text;
    var genre = genreController.text;
    var type = typeController.text;
    var newMovie = Movie.fromMap({
      'id': movie.id,
      'name': name,
      'genre': genre,
      'type': type,
      'priority': this.priority
    });
//    await moviesRepository.updateMovie(movie.id, newMovie);
    Navigator.pop(context, newMovie);
  }

  void submit() async {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState.validate()) {
      if (movie == null) {
        addMovie();
      } else {
        bool connected = await checkConnection();
        if (!connected) {
          showAlertDialog(context, "You cannot update this movie since you are offline!");
        } else {
          updateMovie();
        }
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
//                validator: (value) => this.validator(value),
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
                        onPressed: () async => { await submit() },
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