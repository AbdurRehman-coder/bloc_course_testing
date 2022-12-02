import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:bloc/bloc.dart';
import 'dart:math' as math show Random;

import 'package:flutter/material.dart';

List<String> names = ['Foo', 'Bar', 'Baz'];

extension RandomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(math.Random().nextInt(length));
}

/// Cubit class
class RandomNameCubit extends Cubit<String?> {
  /// constructor
  RandomNameCubit() : super(null);

  void pickedRandomName() => emit(names.getRandomElement());
}

class RandomNameBloc extends StatefulWidget {
  const RandomNameBloc({Key? key}) : super(key: key);

  @override
  State<RandomNameBloc> createState() => _RandomNameBlocState();
}

class _RandomNameBlocState extends State<RandomNameBloc> {
  late final RandomNameCubit nameCubit;

  /// Todo: Just did some stream practice
  // late StreamController<String?> streamController;
  // late Stream<String?> stream;
  //
  // void pickedRandomName() {
  //   streamController.add(names.elementAt(math.Random().nextInt(names.length)));
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameCubit = RandomNameCubit();

    /// Stream Practice
    // streamController = StreamController.broadcast();
    // stream = streamController.stream;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameCubit.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubit Testing'),
      ),
      body: StreamBuilder<String?>(
        stream: nameCubit.stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          final button = TextButton(
            onPressed: () => nameCubit.pickedRandomName(),
            child: const Text('Get random name'),
          );

          /// switch for different connection state
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('No data');
            case ConnectionState.waiting:
              return button;
            case ConnectionState.active:
              return Column(
                children: [
                  Text('Name: ${snapshot.data}'),
                  button,
                ],
              );
            case ConnectionState.done:
              return const Text('Done');
          }
        },
      ),
    );
  }
}
