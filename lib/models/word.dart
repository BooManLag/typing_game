class Word {
  String word;
  int length;

  Word({required this.word, required this.length});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      length: json['length'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['word'] = word;
    data['length'] = length;
    return data;
  }
}
