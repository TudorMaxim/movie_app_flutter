import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app_flutter/form_components/FormWidget.dart';

class AddFormWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Add a movie')
        ),
        body: FormWidget(null)
    );
  }
}