import 'dart:async';
import 'package:event_bloc/event_bloc.dart';
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
  List<Word> _wordGroup = [];
  int _totalKeyPresses = 0;
  int _correctKeyPresses = 0;

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
    // If userInput and word are same, then return true
    if (userInput == word) {
      _correctKeyPresses++; // Increase correct key presses if the word is correct
      _totalKeyPresses++; // Increase total key presses if the input is correct
      _userInput = '';
      _score++;
      _totalWordsTyped++;
      _isIncorrectInputStreamController.add(false);
      _wordCompletedStreamController
          .add(true); // This notifies the UI that the word is completed
      return true;
    }
    // If userInput is the beginning part of the word, then it's partially correct so don't count it as wrong
    else if (word.startsWith(userInput)) {
      _isIncorrectInputStreamController.add(false);
      return false;
    }
    // If userInput is wrong (doesn't match with the start of the word)
    else {
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
        : 100; // This calculation now uses the number of correct key presses and total key presses
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
      // Need to be called every time
      _timePassed++;
      _timerStreamController.add(_timePassed);
    });
    generateWordGroup(); // Generate word group here
  }

  void endGame() {
    _timer.cancel();
    _score = calculateFinalScore();
    resetGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerStreamController.close();
    _wordGroupController.close();
    _isIncorrectInputStreamController.close();
    _wordCompletedStreamController.close();
    super.dispose();
  }
}
