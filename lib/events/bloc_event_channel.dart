import 'dart:async';
import 'dart:html';
import 'package:event_bloc/event_bloc.dart';

class MyEventChannel extends BlocEventChannel {
  final StreamController<Event> _eventController = StreamController<Event>.broadcast();

  @override
  Stream<Event> get eventStream => _eventController.stream;

  @override
  void dispatchEvent(Event event) {
    _eventController.add(event);
  }
}

