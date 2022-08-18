import 'package:flutter/material.dart';

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
 
  const Person({required this.id, required this.firstName,required this.lastName,});
  
  @override
  int compareTo(covariant Person other) => other.id.compareTo(id);

  @override
  bool operator == (covariant Person other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Person, id = $id, firstName: $firstName, lastName: $lastName';
  
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
