import 'dart:async';
import 'package:movie_app_flutter/model/Movie.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbRepository {
  static DbRepository _dbRepository;
  static Database _database;
  final String movieTable = "movies";
  final String moviesDB = "MOVIE_WISHLIST_NONNATIVE.db";

  DbRepository._createInstance();

  factory DbRepository() {
    if (_dbRepository == null) {
      _dbRepository = DbRepository._createInstance(); // singleton
    }
    return _dbRepository;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await init();
    }
    return _database;
  }

  Future<Database> init() async {
    String dbPath = join(await getDatabasesPath(), moviesDB);
    var database = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
    return database;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $movieTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      genre TEXT,
      type TEXT,
      priority REAL)
  ''');
  }

  Future<List<Movie>> getMovies() async {
    final Database db = await database;
    final result = await db.query(movieTable, orderBy: "priority DESC");
    int len = result.length;
    List <Movie> movies = List <Movie>();
    for (int i = 0; i < len; i++) {
      movies.add(Movie.fromMap(result[i]));
    }
    return movies;
  }

  addMovie(Movie movie) async {
    final Database db = await database;
    int id = await db.insert(movieTable, movie.toMap());
    return id;
  }

  updateMovie(int id, Movie newMovie) async {
    final Database db = await database;
    await db.update(
        movieTable,
        newMovie.toMap(),
        where: "id = ?",
      whereArgs: [id]
    );
  }

  deleteMovie(int id) async {
    final Database db = await database;
    await db.delete(
        movieTable,
        where: "id = ?",
        whereArgs: [id]
    );
  }
}