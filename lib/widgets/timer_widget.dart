import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';

class TimerWidget extends StatelessWidget {
  final TypingGameBloc typingGameBloc;

  const TimerWidget({Key? key, required this.typingGameBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: typingGameBloc.timerStream,
      builder: (context, snapshot) {
        return Text('Time: ${typingGameBloc.timePassed}',
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }
}
