import 'package:bloc_course_testing/bloc/person.dart';
import 'package:flutter/foundation.dart' show immutable;

const String person1Url = 'https://jsonplaceholder.typicode.com/posts';
const String person2Url = 'https://jsonplaceholder.typicode.com/albums';
const String person3Url = 'http://127.0.0.1:5500/api/persons2.json';

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

/// Define an action for loading persons
@immutable
class LoadPersonsAction implements LoadAction {
  final String url;
  final PersonsLoader loader;
  const LoadPersonsAction({required this.url, required this.loader}) : super();
}
