import 'package:flutter/material.dart';
import 'package:movie_app_flutter/form_components/AddFormWidget.dart';
import 'package:movie_app_flutter/main_component/MovieList.dart';
import 'package:movie_app_flutter/repository/DbRepository.dart';

void main() => runApp(
    MaterialApp (
      title: "Movie App",
      home: MovieApp()
    )
);

class MovieApp extends StatelessWidget {
  void goToAddForm(context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddFormWidget())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Your wish list')
        ),
        body: MovieList(),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => this.goToAddForm(context)
        )
    );
  }
}