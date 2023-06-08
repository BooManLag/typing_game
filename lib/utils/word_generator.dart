import 'dart:math';
import 'package:typing_game/models/word.dart';

class WordGenerator {
  static const List<String> _consonants = [
    'b',
    'c',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
    'm',
    'n',
    'p',
    'q',
    'r',
    's',
    't',
    'v',
    'w',
    'x',
    'y',
    'z',
  ];
  static const List<String> _vowels = ['a', 'e', 'i', 'o', 'u'];

  final Random _random = Random();

  Word generateWord(int minimumLength) {
    int length = _random.nextInt(6) + 4;
    String word = '';
    bool nextLetterIsConsonant = _random.nextBool();
    for (int i = 0; i < length; i++) {
      if (nextLetterIsConsonant) {
        word += _consonants[_random.nextInt(_consonants.length)];
      } else {
        word += _vowels[_random.nextInt(_vowels.length)];
      }
      nextLetterIsConsonant = !nextLetterIsConsonant;
    }
    return Word(word: word, length: length);
  }

  List<Word> generateWordGroup(int wordGroupSize, int minimumLength) {
    List<Word> words = [];
    for (int i = 0; i < wordGroupSize; i++) {
      Word newWord;
      do {
        newWord = generateWord(minimumLength);
      } while (newWord.word.length < minimumLength);
      words.add(newWord);
    }
    return words.isNotEmpty ? words : [];
  }
}
