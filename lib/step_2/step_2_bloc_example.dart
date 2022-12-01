import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

/// Define an action for loading persons
class LoadPersonsAction implements LoadAction {
  final PersonUrl url;
  const LoadPersonsAction({required this.url}) : super();
}

// enumeration
enum PersonUrl {
  persons1,
  persons2,
}

// Create extension method on PersonUrl enum
extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.persons1:
        // return 'http://127.0.0.1:5500/api/persons1.json';
        return 'https://jsonplaceholder.typicode.com/users';
      case PersonUrl.persons2:
        return 'https://jsonplaceholder.typicode.com/users';
    }
  }
}

// Program the Person
class Person {
  final String name;
  final int id;
  // default constructor
  const Person({
    required this.name,
    required this.id,
  });
// constructor for json
  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        id = json['id'] as int;
}

// now download and parse JSON
// for this we don't really need to use third party packages like http & dio
// insteade we will use dart built-in "httpClient"
// Future<Iterable<Person>> getPersons(String url) async {
//   print('get person called..');
//   List<Person> persons = [];
//   final response = await http.get(Uri.parse(url));
//   print('http response is: ${response}');
//   if (response.statusCode == 200) {
//     var responseBody = response.body;
//     print('response body: ${responseBody}');
//     var jsonDecoded = json.decode(responseBody);
//     List values = jsonDecoded as List;
//     persons = values
//         .map(
//           (e) => Person.fromJson(e),
//         )
//         .toList();

//     return persons;
//   } else {
//     print('status code error');
//     return persons;
//   }
// }

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

// Define result of the bloc
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });
  // toString
  String toString() =>
      'FetchResult: (isRetrievedFromCache: $isRetrievedFromCache , Persons: $persons';
}

// Write the Bloc class
class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  // We need a cache in the bloc
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  // bloc's constructor
  PersonsBloc() : super(null) {
    // Handle the LoadPersonActions in the constructor
    on<LoadPersonsAction>((event, emit) async {
      final url = event.url;
      // check if the fetched result already in cache
      if (_cache.containsKey(url)) {
        final cachedPerson = _cache[url]!;
        final result = FetchResult(
          persons: cachedPerson,
          isRetrievedFromCache: true,
        );
        emit(result);
      } else {
        final persons = await getPersons(url.urlString);
        _cache[url] = persons;
        final result = FetchResult(
          persons: persons,
          isRetrievedFromCache: false,
        );
        emit(result);
      }
    });
  }
}

// Use this extension for make the iterable value accessing optional
extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class Step2Example extends StatefulWidget {
  const Step2Example({super.key});

  @override
  State<Step2Example> createState() => _Step2ExampleState();
}

class _Step2ExampleState extends State<Step2Example> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2'),
      ),
      body: Column(children: [
        Row(
          children: [
            TextButton(
              onPressed: () {
                context.read<PersonsBloc>().add(
                      const LoadPersonsAction(url: PersonUrl.persons1),
                    );
              },
              child: const Text('Load Json # 1'),
            ),
            TextButton(
              onPressed: () {
                context.read<PersonsBloc>().add(
                      const LoadPersonsAction(url: PersonUrl.persons2),
                    );
              },
              child: const Text('Load Json # 2'),
            ),
          ],
        ),
        // BlocBuilder for rendering the new state of the Bloc into the widget
        BlocBuilder<PersonsBloc, FetchResult?>(
          buildWhen: (previousResult, currentResult) {
            return previousResult?.persons != currentResult?.persons;
          },
          builder: ((context, fetchResult) {
            fetchResult?.log();
            final persons = fetchResult?.persons;
            if (persons == null) {
              return const SizedBox();
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: ((context, index) {
                    final person = persons[index];
                    return ListTile(
                      leading: Text(person!.id.toString()),
                      title: Text(person.name),
                    );
                  }),
                ),
              );
            }
          }),
        ),
      ]),
    );
  }
}
