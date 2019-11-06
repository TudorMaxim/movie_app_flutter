import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app_flutter/form_components/FormWidget.dart';
import 'package:movie_app_flutter/repository/Repository.dart';

class AddFormWidget extends StatelessWidget {
  final Repository moviesRepository;

  AddFormWidget(this.moviesRepository);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Add a movie')
        ),
        body: FormWidget(null,  moviesRepository)
    );
  }
}