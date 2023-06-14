import 'package:flutter/material.dart';
import 'package:typing_game/blocs/typing_game_bloc.dart';
import 'package:typing_game/models/word.dart';

class WordGroupWidget extends StatelessWidget {
  final TypingGameBloc typingGameBloc;

  const WordGroupWidget(
      {super.key, required this.typingGameBloc, required String userInput});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: typingGameBloc.currentWordStream,
      builder: (context, snapshot) {
        String currentWord = snapshot.data ?? '';
        return StreamBuilder<List<Word>>(
          stream: typingGameBloc.wordGroupStream,
          builder: (BuildContext context, AsyncSnapshot<List<Word>> snapshot) {
            if (snapshot.hasData) {
              List<Word> wordGroup = snapshot.data!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: wordGroup.map((Word word) {
                  bool isCurrentWord = word.word == currentWord;
                  return Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: word.word.split('').asMap().entries.map((e) {
                      bool hasTyped = typingGameBloc.userInput.length > e.key;
                      bool isCorrect = hasTyped &&
                          typingGameBloc.userInput[e.key] == e.value;
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
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        );
      },
    );
  }
}
