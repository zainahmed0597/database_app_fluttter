import 'dart:async';

import 'package:flutter/material.dart';

import 'DB/person_db.dart';
import 'DB/person_notes.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PersonDB _crudStorage;

  @override
  void initState() {
    _crudStorage = PersonDB(dbName: 'db.sqlite');
    _crudStorage.open();
    super.initState();
  }

  @override
  void dispose() {
    _crudStorage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'CRUD',
        ),
      ),
      body: StreamBuilder(
        stream: _crudStorage.all(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              if (snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final people = snapshot.data as List<Person>;
              return Column(
                children: [
                  ComposeWidget(
                    onCompose: (firstName, lastName) async {
                      await _crudStorage.create(firstName, lastName);
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: people.length,
                      itemBuilder: (context, index) {
                        final person = people[index];
                        return ListTile(
                          onTap: () async {
                            final editedPerson =
                                await showUpdateDialog(context, person);
                            if (editedPerson != null) {
                              await _crudStorage.update(editedPerson);
                            }
                          },
                          title: Text(person.fullName),
                          subtitle: Text('ID: ${person.id}'),
                          trailing: TextButton(
                            onPressed: () async {
                              final shouldDelete =
                                  await showDeleteDialog(context);
                              print(shouldDelete);
                              if (shouldDelete) {
                                await _crudStorage.delete(person);
                              }
                            },
                            child: const Icon(
                              Icons.disabled_by_default,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );

            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}

Future<bool> showDeleteDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  ).then((value) {
    if (value is bool) {
      return value;
    } else {
      return false;
    }
  });
}

final _firstNameController = TextEditingController();
final _lastNameController = TextEditingController();
Future<Person?> showUpdateDialog(BuildContext context, Person person) {
  _firstNameController.text = person.firstName;
  _lastNameController.text = person.lastName;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your updated value here:',
            ),
            TextField(
              controller: _firstNameController,
            ),
            TextField(
              controller: _lastNameController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final editedPerson = Person(
                id: person.id,
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
              );
              Navigator.of(context).pop(editedPerson);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

typedef OnCompose = void Function(String firstName, String lastName);

class ComposeWidget extends StatefulWidget {
  final OnCompose onCompose;
  const ComposeWidget({Key? key, required this.onCompose}) : super(key: key);

  @override
  State<ComposeWidget> createState() => _ComposeWidgetState();
}

class _ComposeWidgetState extends State<ComposeWidget> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(hintText: 'Enter first name'),
          ),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(hintText: 'Enter last name'),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6.0),
            ),
            height: 30.0,
            width: 150.0,
            child: TextButton(
              onPressed: () {
                final firstName = _firstNameController.text;
                final lastName = _lastNameController.text;
                widget.onCompose(firstName, lastName);
                _firstNameController.text = '';
                _lastNameController.text = '';
              },
              child: const Center(
                child: Text(
                  'Add to list',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
