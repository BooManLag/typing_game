import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';

import '../blocs/typing_game_bloc.dart';

class EndGameButton extends StatelessWidget {
  final VoidCallback onEndGame;

  const EndGameButton({super.key, required this.onEndGame});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.fireEvent<void>(
          RESET_GAME_EVENT as BlocEventType<void>, null),
      child: const Text('End Game'),
    );
  }
}
