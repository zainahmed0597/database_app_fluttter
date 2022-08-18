import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),     
    ),
  );
}

class Person implements Comparable {
  final int id;
  final String firstName;
  final String lastName;
 
  const Person({ 
    required this.id, 
    required this.firstName,
    required this.lastName,
  });
   
  @override
  int compareTo(covariant Person other) => other.id.compareTo(id);

  @override
  bool operator == (covariant Person other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Person, id = $id, firstName: $firstName, lastName: $lastName';
  
}

class PersonDB{
  final String dbName;
  Database?  _db;
  List<Person> peoples =[];

  PersonDB(this.dbName);

  Future<bool> open() async{
    if(_db != null){
      return true;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path ='${directory.path}/db.sqlite';
    try{
      final db = await openDatabase(path);
      _db = db;

      // sql create table 
      const create = '''CREATE TABLE IF NOT EXISTS PEOPLE(
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        FIRST_NAME STRING NOT NULL,
        LAST_NAME STRING NOT NULL
      )''';

      await db.execute(create);

    } catch(e){
      print('Error$e');
      return false;
    }
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'CRUD',
        ),
      ),
    );
  }
}
