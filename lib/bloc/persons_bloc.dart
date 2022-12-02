// Write the Bloc class
import 'package:bloc_course_testing/bloc/bloc_actions.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'person.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

// Define result of the bloc
@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });
  // toString
  @override
  String toString() =>
      'FetchResult: (isRetrievedFromCache: $isRetrievedFromCache , Persons: $persons';

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashcode => Object.hash(persons, isRetrievedFromCache);
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  // We need a cache in the bloc
  final Map<String, Iterable<Person>> _cache = {};
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
        final loader = event.loader;
        final persons = await loader(url);
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
