import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';
import 'package:typing_game/models/word.dart';
import 'package:typing_game/widgets/timer_widget.dart';
import 'package:typing_game/widgets/word_group_widget.dart';
import 'accuracy_widget.dart';
import 'end_game_button.dart';
import 'input_field_widget.dart';

class TypingGame extends StatefulWidget {
  final TypingGameBloc typingGameBloc;
  TypingGame({Key? key, required this.typingGameBloc}) : super(key: key);

  @override
  _TypingGameState createState() => _TypingGameState();
}

class _TypingGameState extends State<TypingGame> {
  List<Word> _wordGroup = [];
  TextEditingController _textEditingController = TextEditingController();
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
    _textEditingController.addListener(() {
      setState(() {
        _userInput = _textEditingController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WordGroupWidget(
          typingGameBloc: widget.typingGameBloc,
          userInput: _userInput, // Pass the user input to WordGroupWidget
        ),
        const SizedBox(height: 20.0),
        InputFieldWidget(
          typingGameBloc: widget.typingGameBloc,
          textEditingController: _textEditingController,
        ),
        const SizedBox(height: 20.0),
        // Display the current score
        Text('Score: ${widget.typingGameBloc.calculateFinalScore()}'),
        const SizedBox(height: 20.0),
        // Accuracy widget
        AccuracyWidget(typingGameBloc: widget.typingGameBloc),
        const SizedBox(height: 20.0),
        // Timer widget
        TimerWidget(typingGameBloc: widget.typingGameBloc),
        const SizedBox(height: 20.0),
        // End game button
        EndGameButton(onEndGame: widget.typingGameBloc.endGame),
      ],
    );
  }
}
