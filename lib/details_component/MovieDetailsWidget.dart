
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app_flutter/form_components/UpdateFormWidget.dart';
import 'package:movie_app_flutter/model/Movie.dart';

class MovieDetailsWidget extends StatelessWidget {
  final Movie movie;

  MovieDetailsWidget(this.movie);

  void goToUpdateForm(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => UpdateFormWidget(movie))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.name),
      ),
      body: Column(
        children: [
          Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Genre:", style: TextStyle(fontSize: 24))
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(movie.genre, style: TextStyle(fontSize: 24)),
              )
            ],
          ),
          Row (
            children: [
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Type:", style: TextStyle(fontSize: 24))
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(movie.type, style: TextStyle(fontSize: 24)),
              )
            ]
          ),
          Row (
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Priority:", style: TextStyle(fontSize: 24))
              ),
              RatingBarIndicator(
                rating: movie.priority,
                direction: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
                )
              )
            ],
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.edit),
          onPressed: () => this.goToUpdateForm(context)
      )
    );
  }
}