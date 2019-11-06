import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_app_flutter/details_component/MovieDetailsWidget.dart';
import 'package:movie_app_flutter/model/Movie.dart';
import 'package:movie_app_flutter/repository/Repository.dart';

class MovieWidget extends StatelessWidget {
  final Movie movie;
  final Repository moviesRepository;
  MovieWidget(this.movie, this.moviesRepository);

  void goToDetails(context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MovieDetailsWidget(this.movie, moviesRepository)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return  ListTile (
      contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
      title: Text(movie.name),
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
      onTap: () => goToDetails(context)
    );
  }
}