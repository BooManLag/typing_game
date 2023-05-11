import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';
import 'package:typing_game/models/word.dart';
import 'package:typing_game/widgets/timer_widget.dart';
import 'accuracy_widget.dart';
import 'end_game_button.dart';

class TypingGame extends StatefulWidget {
  final TypingGameBloc typingGameBloc;
  const TypingGame({Key? key, required this.typingGameBloc}) : super(key: key);

  @override
  _TypingGameState createState() => _TypingGameState();
}

class _TypingGameState extends State<TypingGame> {
  List<Word> _wordGroup = [];
  String _userInput = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      widget.typingGameBloc.wordGroupStream.listen((wordGroup) {
        setState(() {
          _wordGroup = wordGroup;
        });
      });
      widget.typingGameBloc.generateWordGroup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the current word group
        _buildWordGroup(),
        // Input field for user input
        _buildInputField(),
        // Display the current score
        Text('Score: ${widget.typingGameBloc.calculateFinalScore()}'),
        // Accuracy widget
        AccuracyWidget(typingGameBloc: widget.typingGameBloc),
        // Timer widget
        TimerWidget(typingGameBloc: widget.typingGameBloc),
        // End game button
        EndGameButton(onEndGame: widget.typingGameBloc.endGame),
      ],
    );
  }

  Widget _buildWordGroup() {
    return Column(
      children: _wordGroup.map((word) {
        return Text(word.word);
      }).toList(),
    );
  }

  Widget _buildInputField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _userInput = value;
        });
        // Check if the user input matches the current word
        if (widget.typingGameBloc
            .checkUserInput(_userInput, _wordGroup[0].word)) {
          // If it matches, remove the word from the word group
          _wordGroup.removeAt(0);
          // And generate a new word group if necessary
          if (_wordGroup.isEmpty) {
            widget.typingGameBloc.generateWordGroup();
          }
          // Reset the user input
          _userInput = '';
        }
      },
      onSubmitted: (_) {
        // Calculate accuracy when the user presses enter
        widget.typingGameBloc.calculateAccuracy();
      },
    );
  }
}
