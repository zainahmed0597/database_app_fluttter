import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'person_notes.dart';

class PersonDB {
  final String dbName;
  Database? _db;
  List<Person> _persons = [];
  final _streamController = StreamController<List<Person>>.broadcast();
  PersonDB({required this.dbName});

  // C in CRUD create in DB
  Future<bool> create(String firstName, String lastName) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final id = await db.insert('PEOPLE', {
        'FIRST_NAME': firstName,
        'LAST_NAME': lastName,
      });
      final person = Person(id: id, firstName: firstName, lastName: lastName);
      _persons.add(person);
      _streamController.add(_persons);
      print('1');
      return true;
    } catch (e) {
      print('Error in creating  person = $e');
      print('2');
      return false;
    }
  }

  // R in CRUD read in DB
  Future<List<Person>> _fetchPeople() async {
    final db = _db;
    if (db == null) {
      return [];
    }
    try {
      final read = await db.query('PEOPLE',
          distinct: true,
          columns: ['ID', 'FIRST_NAME', 'LAST_NAME'],
          orderBy: 'ID');
      final people = read.map((row) => Person.fromRow(row)).toList();
      return people;
    } catch (e) {
      print('Error fetching people = $e');
      return [];
    }
  }

  // U is CRUD update in DB
  Future<bool> update(Person person) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final updateCount = await db.update(
        'PEOPLE',
        {
          'FIRST_NAME': person.firstName,
          'LAST_NAME': person.lastName,
        },
        where: 'ID = ?',
        whereArgs: [person.id],
      );
      if (updateCount == 1) {
        _persons.removeWhere((other) => other.id == person.id);
        _persons.add(person);
        _streamController.add(_persons);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Failed to update person error = $e');
      return false;
    }
  }

  // D in CRUD delete in DB
  Future<bool> delete(Person person) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final deletedCount =
          await db.delete('PEOPLE', where: 'ID = ?', whereArgs: [person.id]);
      if (deletedCount == 1) {
        _persons.remove(person);
        _streamController.add(_persons);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Deletion failed with error $e');
      return false;
    }
  }

  // open DB
  Future<bool> open() async {
    if (_db != null) {
      return true;
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/db.sqlite';
    try {
      final db = await openDatabase(path);
      _db = db;

      // sql create table
      const create = '''CREATE TABLE IF NOT EXISTS PEOPLE(
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        FIRST_NAME STRING NOT NULL,
        LAST_NAME STRING NOT NULL
      )''';

      await db.execute(create);

      //read all existing Person object from the db
      _persons = await _fetchPeople();
      _streamController.add(_persons);
      return true;
    } catch (e) {
      print('Error$e');
      return false;
    }
  }

  // close DB
  Future<bool> close() async {
    final db = _db;
    if (db == null) {
      return false;
    }
    await db.close();
    return true;
  }

  Stream<List<Person>> all() =>
      _streamController.stream.map((person) => person..sort());
}
