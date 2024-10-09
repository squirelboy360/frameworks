import 'dart:async';

class Store<T> {
  T _state;
  final StreamController<T> _stateController = StreamController<T>.broadcast();

  Store(this._state);

  T get state => _state;

  Stream<T> get stream => _stateController.stream;

  void setState(T newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void dispose() {
    _stateController.close();
  }
}