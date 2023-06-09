import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';

class InputFieldWidget extends StatelessWidget {
  final TypingGameBloc typingGameBloc;
  final TextEditingController textEditingController;

  const InputFieldWidget({
    Key? key,
    required this.typingGameBloc,
    required this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: typingGameBloc.wordCompletedStream,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.data!) {
          textEditingController.clear();
        }
        return StreamBuilder<bool>(
          stream: typingGameBloc.isIncorrectInputStream,
          initialData: false,
          builder: (context, snapshot) {
            bool isIncorrect = snapshot.data!;
            return TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isIncorrect ? Colors.red : Colors.green,
                  ),
                ),
              ),
              onChanged: (value) {
                typingGameBloc.handleKeyPress(value);
              },
              onSubmitted: (_) {
                textEditingController.clear();
              },
            );
          },
        );
      },
    );
  }
}
