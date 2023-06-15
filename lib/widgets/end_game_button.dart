import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';

class EndGameButton extends StatelessWidget {
  final TypingGameBloc typingGameBloc;

  const EndGameButton(
      {Key? key,
      required this.typingGameBloc,
      required TextEditingController textEditingController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        typingGameBloc.endGame();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Game Over'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Final Score: ${typingGameBloc.finalScore}'),
                Text('Accuracy: ${typingGameBloc.finalAccuracy}%'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  typingGameBloc.resetGame(); // Reset the game
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
      child: const Text('End Game'),
    );
  }
}
