import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app_flutter/form_components/FormWidget.dart';
import 'package:movie_app_flutter/model/Movie.dart';

class UpdateFormWidget extends StatelessWidget {
  final Movie movie;

  UpdateFormWidget(this.movie);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Update a movie')
        ),
        body: FormWidget(movie)
    );
  }
}