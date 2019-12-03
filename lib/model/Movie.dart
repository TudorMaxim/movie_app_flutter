
class Movie {
  final int id;
  final String name, genre, type;
  final double priority;

  Movie({this.id, this.name, this.genre, this.type, this.priority});

  equals(Movie other) {
      return this.id == other.id && this.name == other.name &&
          this.genre == other.genre && this.type == other.type && this.priority == other.priority;
  }

  Movie copy() {
    return Movie(
      id: this.id,
      name: this.name,
      type: this.type,
      genre: this.genre,
      priority: this.priority
    );
  }

  toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    map['genre'] = genre;
    map['type'] = type;
    map['priority'] = priority;
    return map;
  }

  static List toJsonList(List <Movie> movies) {
    List jsonList = List();
    movies.map((movie) => jsonList.add(movie.toMap())).toList();
    return jsonList;
  }

  Movie.fromMap(Map<String, dynamic> map):
        id = map['id'],
        name = map['name'],
        genre = map['genre'],
        type = map['type'],
        priority = map['priority'].toDouble();
}