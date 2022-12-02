import 'dart:convert';
import 'dart:io';
import 'package:bloc_course_testing/bloc/bloc_actions.dart';
import 'package:bloc_course_testing/bloc/person.dart';
import 'package:bloc_course_testing/bloc/persons_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
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
                      const LoadPersonsAction(
                          url: person1Url, loader: getPersons),
                    );
              },
              child: const Text('Load Json # 1'),
            ),
            TextButton(
              onPressed: () {
                context.read<PersonsBloc>().add(
                      const LoadPersonsAction(
                          url: person2Url, loader: getPersons),
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
                      title: Text(person.title),
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
