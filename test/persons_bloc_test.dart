import 'package:bloc_course_testing/bloc/bloc_actions.dart';
import 'package:bloc_course_testing/bloc/person.dart';
import 'package:bloc_course_testing/bloc/persons_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

const mockedPersons1 = [
  Person(id: 400, title: 'testing mock1 1'),
  Person(id: 500, title: 'testing mock1 2')
];

const mockedPersons2 = [
  Person(id: 400, title: 'testing mock2 1'),
  Person(id: 500, title: 'testing mock2 2')
];

// define two mocked functions
Future<Iterable<Person>> mockGetPersons1(String _) =>
    Future.value(mockedPersons1);

Future<Iterable<Person>> mockGetPersons2(String _) =>
    Future.value(mockedPersons2);

void main() {
  group(
    'Testing bloc',
    () {
      late PersonsBloc personsBloc;

      setUp(() {
        personsBloc = PersonsBloc();
      });

      blocTest<PersonsBloc, FetchResult?>(
        'Testing the initial state',
        build: () => personsBloc,
        verify: ((bloc) => expect(bloc.state, null)),
      );

      // fetch mock data (person 1) and compare it with FetchResult
      blocTest<PersonsBloc, FetchResult?>(
        'Mock retrieving person from first iterable',
        build: () => personsBloc,
        act: ((bloc) {
          bloc.add(
            const LoadPersonsAction(
              url: 'dummy_url_1',
              loader: mockGetPersons1,
            ),
          );

          bloc.add(
            const LoadPersonsAction(
              url: 'dummy_url_1',
              loader: mockGetPersons1,
            ),
          );
        }),
        expect: (() => [
              const FetchResult(
                persons: mockedPersons1,
                isRetrievedFromCache: false,
              ),
              const FetchResult(
                persons: mockedPersons1,
                isRetrievedFromCache: true,
              ),
            ]),
      );

      // fetch mock data (person 2) and compare it with FetchResult
      blocTest<PersonsBloc, FetchResult?>(
        'Mock retrieving person from second iterable',
        build: () => personsBloc,
        act: ((bloc) {
          bloc.add(
            const LoadPersonsAction(
              url: 'dummy_url_2',
              loader: mockGetPersons2,
            ),
          );

          bloc.add(
            const LoadPersonsAction(
              url: 'dummy_url_2',
              loader: mockGetPersons2,
            ),
          );
        }),
        expect: (() => [
              const FetchResult(
                persons: mockedPersons2,
                isRetrievedFromCache: false,
              ),
              const FetchResult(
                persons: mockedPersons2,
                isRetrievedFromCache: true,
              ),
            ]),
      );
    },
  );
}
