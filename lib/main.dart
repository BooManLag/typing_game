import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';
import 'package:typing_game/widgets/typing_game.dart';

void main() {
  runApp(
    BlocProvider<TypingGameBloc>(
      create: (context, channel) => TypingGameBloc(channel, parentChannel: channel),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final typingGameBloc = BlocProvider.watch<TypingGameBloc>(context);
    return MaterialApp(
      home: Scaffold(
        body: TypingGame(typingGameBloc: typingGameBloc),
      ),
    );
  }
}

