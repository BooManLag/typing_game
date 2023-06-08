import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';
import 'package:typing_game/models/word.dart';
import 'package:typing_game/widgets/timer_widget.dart';
import 'accuracy_widget.dart';
import 'end_game_button.dart';

class TypingGame extends StatefulWidget {
  final TypingGameBloc typingGameBloc;
  TypingGame({Key? key, required this.typingGameBloc}) : super(key: key);

  @override
  _TypingGameState createState() => _TypingGameState();
}

class _TypingGameState extends State<TypingGame> {
  List<Word> _wordGroup = [];
  String _userInput = '';
  final TextEditingController _textEditingController = TextEditingController();

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
    return StreamBuilder<String>(
        stream: widget.typingGameBloc.currentWordStream,
        builder: (context, snapshot) {
          String currentWord = snapshot.data ?? '';
          return StreamBuilder<List<Word>>(
            stream: widget.typingGameBloc.wordGroupStream,
            builder: (BuildContext context, AsyncSnapshot<List<Word>> snapshot) {
              if (snapshot.hasData) {
                _wordGroup = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _wordGroup.map((Word word) {
                    bool isCurrentWord = word.word == currentWord;
                    return Wrap(
                      spacing: 2.0, // gap between adjacent chips
                      runSpacing: 2.0, // gap between lines
                      direction: Axis.horizontal, // main axis (rows or columns)
                      children: word.word.split('').asMap().entries.map((e) {
                        bool hasTyped = _userInput.length > e.key;
                        bool isCorrect = hasTyped && _userInput[e.key] == e.value;
                        Color color;
                        if (isCurrentWord) {
                          if (hasTyped) {
                            color = isCorrect ? Colors.green : Colors.red;
                          } else {
                            color = Colors.grey;
                          }
                        } else {
                          color = Colors.grey;
                        }
                        return Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            e.value,
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              } else {
                return CircularProgressIndicator(); // a loading indicator
              }
            },
          );
        });
  }


  Widget _buildInputField() {
    return StreamBuilder<bool>(
        stream: widget.typingGameBloc.wordCompletedStream,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data!) {
            _textEditingController.clear();
          }
          return StreamBuilder<bool>(
            stream: widget.typingGameBloc.isIncorrectInputStream,
            initialData: false,
            builder: (context, snapshot) {
              bool isIncorrect = snapshot.data!;
              return TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isIncorrect ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                onChanged: (value) {
                  _userInput = value;
                  widget.typingGameBloc.handleKeyPress(_userInput);
                },
                onSubmitted: (_) {
                  setState(() {
                    _userInput = '';
                  });
                },
              );
            },
          );
        });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
