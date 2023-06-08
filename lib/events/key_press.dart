class TypingGameEvent {
  const TypingGameEvent();
}

class KeyPressEvent extends TypingGameEvent {
  final String key;

  KeyPressEvent(this.key);
}
