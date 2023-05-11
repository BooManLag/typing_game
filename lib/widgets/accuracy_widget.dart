import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';

class AccuracyWidget extends StatelessWidget {
  final TypingGameBloc typingGameBloc;

  const AccuracyWidget({super.key, required this.typingGameBloc});

  @override
  Widget build(BuildContext context) {
    int accuracy = typingGameBloc.accuracy;
    return StreamBuilder<int>(
      stream: typingGameBloc.timerStream,
      builder: (context, snapshot) {
        return Text('Accuracy: $accuracy%',
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }
}
