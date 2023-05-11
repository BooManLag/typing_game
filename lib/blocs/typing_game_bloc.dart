// ignore_for_file: unused_import
import 'dart:async';
import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/services.dart';
import 'package:typing_game/models/word.dart';
import 'package:typing_game/utils/word_generator.dart';

const RESET_GAME_EVENT = 'reset-game';
//instead of initializing the bloc in the initState method,
// we can use the BlocProvider widget to initialize the bloc and
// pass it down to the TypingGame widget.
class TypingGameBloc extends Bloc {
  int _score = 0;
  int _totalWordsTyped = 0;
  int _accuracy = 100;
  int get accuracy => _accuracy;

  int _timePassed = 0;
  Timer _timer = Timer.periodic(const Duration(seconds: 1), (timer) {});
  final StreamController<int> _timerStreamController =
  StreamController<int>.broadcast();

  int get timePassed => _timePassed;
  Stream<int> get timerStream => _timerStreamController.stream;

  final int _minimumLength = 4;
  final int _wordGroupSize = 3;
  final WordGenerator _wordGenerator = WordGenerator();
  final StreamController<List<Word>> _wordGroupController =
  StreamController<List<Word>>.broadcast();

  Stream<List<Word>> get wordGroupStream => _wordGroupController.stream;

  @override
  BlocEventChannel get eventChannel => BlocEventChannel();

  TypingGameBloc(BlocEventChannel? eventChannel,
      {required super.parentChannel}) {
    eventChannel?.addEventListener(
        RESET_GAME_EVENT as BlocEventType<Object?>, (_, __) => resetGame());

    // Start the timer when the bloc is created
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timePassed++;
      _timerStreamController.add(_timePassed);
    });
  }

  void generateWordGroup() {
    List<Word> wordGroup = _wordGenerator.generateWordGroup(_wordGroupSize, _minimumLength);
    _wordGroupController.add(wordGroup);
  }


  bool checkUserInput(String input, String correctWord) {
    if (input == correctWord) {
      _score++;
      _totalWordsTyped++;
      return true;
    } else {
      _totalWordsTyped++;
      return false;
    }
  }

  void calculateAccuracy() {
    _accuracy = ((_score / _totalWordsTyped) * 100).round();
    updateBloc();
  }

  int calculateFinalScore() {
    return (_score * _accuracy) ~/ 100;
  }

  void resetGame() {
    _score = 0;
    _totalWordsTyped = 0;
    _accuracy = 100;
    _timer.cancel();
    _timePassed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timePassed++;
      _timerStreamController.add(_timePassed);
    });
    generateWordGroup();
  }

  void endGame() {
    // Stop the timer
    _timer.cancel();
    // Calculate the final score
    _score = calculateFinalScore();
    // Reset the game for the next round
    resetGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerStreamController.close();
    _wordGroupController.close();
    super.dispose();
  }
}
