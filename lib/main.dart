import 'package:flutter/material.dart';
import 'package:movie_app_flutter/form_components/AddFormWidget.dart';
import 'package:movie_app_flutter/main_component/MovieList.dart';
import 'package:movie_app_flutter/repository/Repository.dart';

void main() => runApp(
    MaterialApp (
      title: "Movie App",
      home: MovieApp()
    )
);

class MovieApp extends StatelessWidget {
  final Repository moviesRepository = new Repository();

  void goToAddForm(context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddFormWidget(moviesRepository))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Your wish list')
        ),
        body: MovieList(moviesRepository),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => this.goToAddForm(context)
        )
    );
  }
}