import 'dart:async';
import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:typing_game/models/word.dart';
import 'package:typing_game/utils/word_generator.dart';

import '../events/bloc_event_channel.dart';
import '../events/key_press.dart';

const RESET_GAME_EVENT = 'reset-game';
const KEY_PRESS_EVENT = 'key-press-event';

class TypingGameBloc extends Bloc {
  int _score = 0;
  int _totalWordsTyped = 0;
  int _accuracy = 100;
  int get accuracy => _accuracy;
  int _finalAccuracy = 100;
  int _finalScore = 0;
  int get finalAccuracy => _finalAccuracy;
  int get finalScore => _finalScore;
  List<Word> _wordGroup = [];
  int _totalKeyPresses = 0;
  int _correctKeyPresses = 0;
  TextEditingController _textEditingController = TextEditingController();

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

  String _userInput = '';
  String get userInput => _userInput;

  set userInput(String value) {
    _userInput = value;
    handleKeyPress(_userInput);
  }

  String? _currentWord;
  final StreamController<String> _currentWordController =
      StreamController<String>.broadcast();
  Stream<String> get currentWordStream => _currentWordController.stream;

  final StreamController<bool> _wordCompletedStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get wordCompletedStream => _wordCompletedStreamController.stream;

  final StreamController<int> _scoreStreamController =
      StreamController<int>.broadcast();
  Stream<int> get scoreStream => _scoreStreamController.stream;

  final StreamController<int> _finalAccuracyStreamController =
      StreamController<int>.broadcast();
  Stream<int> get finalAccuracyStream => _finalAccuracyStreamController.stream;

  final StreamController<int> _accuracyStreamController =
      StreamController<int>.broadcast();
  Stream<int> get accuracyStream => _accuracyStreamController.stream;

  @override
  BlocEventChannel get eventChannel => MyEventChannel();

  final StreamController<bool> _isIncorrectInputStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get isIncorrectInputStream =>
      _isIncorrectInputStreamController.stream;

  bool _isIncorrectInput = false;
  bool get isIncorrectInput => _isIncorrectInput;

  TypingGameBloc(
    BlocEventChannel? channel, {
    required BlocEventChannel parentChannel,
    BlocEventChannel? eventChannel,
  }) : super(parentChannel: parentChannel) {
    _accuracyStreamController.add(_accuracy);
    eventChannel?.addEventListener(
        RESET_GAME_EVENT as BlocEventType<Object?>, (_, __) => resetGame());
    eventChannel?.addEventListener(KEY_PRESS_EVENT as BlocEventType<String>,
        (_, key) => handleKeyPress(key));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timePassed++;
      _timerStreamController.add(_timePassed);
    });
    generateWordGroup();
  }

  void handleKeyPress(String inputWord) {
    _userInput = inputWord;

    if (_currentWord == null || _currentWord!.isEmpty) {
      generateWordGroup();
    }

    if (checkUserInput(_userInput, _currentWord!)) {
      _wordGroup.removeAt(0);
      if (_wordGroup.isEmpty) {
        generateWordGroup();
      } else {
        _currentWord = _wordGroup[0].word;
        _currentWordController.add(_currentWord!);
      }
      _wordCompletedStreamController.add(true);
    } else {
      _wordCompletedStreamController.add(false);
    }

    calculateAccuracy(); // Recalculate accuracy after each key press
  }

  bool checkUserInput(String userInput, String word) {
    if (userInput == word) {
      _correctKeyPresses++; // Increase correct key presses if the word is correct
      _totalKeyPresses++; // Increase total key presses if the input is correct
      _userInput = '';
      _score++;
      _totalWordsTyped++;
      _isIncorrectInputStreamController.add(false);
      _wordCompletedStreamController
          .add(true); // This notifies the UI that the word is completed

      // Update the score stream
      _scoreStreamController.add(_score);

      return true;
    } else if (word.startsWith(userInput)) {
      _isIncorrectInputStreamController.add(false);
      return false;
    } else {
      _totalKeyPresses++; // Increase total key presses if the input is wrong
      _isIncorrectInputStreamController.add(true);
      return false;
    }
  }

  void generateWordGroup() {
    _wordGroup = List.generate(
      _wordGroupSize,
      (_) => _wordGenerator.generateWord(_minimumLength),
    );
    _wordGroupController.add(_wordGroup);
    _currentWord = _wordGroup[0].word;
    _currentWordController.add(_currentWord!);
    _isIncorrectInput = true;
    _isIncorrectInputStreamController.add(_isIncorrectInput);
  }

  void calculateAccuracy() {
    _accuracy = (_correctKeyPresses > 0 && _totalKeyPresses > 0)
        ? ((_correctKeyPresses / _totalKeyPresses) * 100).round()
        : 100;
    _accuracyStreamController.add(_accuracy); // Update the accuracy stream
    updateBloc();
  }

  void resetGame() {
    _score = 0;
    _totalWordsTyped = 0;
    _correctKeyPresses = 0;
    _totalKeyPresses = 0;
    _userInput = ''; // Clear the user input
    _accuracy = 100; // Reset the accuracy to 100
    _accuracyStreamController.add(_accuracy); // Update the accuracy stream
    _timer.cancel();
    _timePassed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Need to be called every time
      _timePassed++;
      _timerStreamController.add(_timePassed);
    });
    generateWordGroup(); // Generate word group here
    _scoreStreamController.add(_score); // Update the score stream with the new score
  }


  void endGame() {
    _timer.cancel();
    _finalAccuracy = _accuracy; // Store the current accuracy as the final accuracy
    _finalScore = _score; // Store the current score as the final score
    _score = 0; // Reset the score to 0
    resetGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerStreamController.close();
    _wordGroupController.close();
    _isIncorrectInputStreamController.close();
    _wordCompletedStreamController.close();
    _scoreStreamController.close();
    _finalAccuracyStreamController
        .close(); // Close the finalAccuracyStreamController
    super.dispose();
  }
}
