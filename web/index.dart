import 'dart:html';
import 'package:redux/redux.dart';
import 'package:redux_saga/redux_saga.dart';
import 'package:saga_monitor/saga_monitor.dart';

void render(int state) {
  querySelector('#value').innerHtml = '$state';
}

int counterReducer(int state, dynamic action) {
  if (action is IncrementAction) {
    return state + 1;
  } else if (action is DecrementAction) {
    return state - 1;
  }

  return state;
}

//Actions
class IncrementAction {}

class DecrementAction {}

class IncrementAsyncAction {}

incrementAsync({action}) sync* {
  yield Delay(Duration(seconds: 1));
  yield Put(IncrementAction());
}

counterSaga() sync* {
  yield TakeEvery(incrementAsync, pattern: IncrementAsyncAction);
}

void main() {
  var monitor = SimpleSagaMonitor(
      onLog: consoleMonitorLogger);

  var sagaMiddleware = createSagaMiddleware(Options(sagaMonitor: monitor));

  // Create store and apply middleware
  final store = Store(
    counterReducer,
    initialState: 0,
    middleware: [applyMiddleware(sagaMiddleware)],
  );

  sagaMiddleware.setStore(store);

  sagaMiddleware.run(counterSaga);

  render(store.state);
  store.onChange.listen(render);

  querySelector('#increment').onClick.listen((_) {
    store.dispatch(IncrementAction());
  });

  querySelector('#decrement').onClick.listen((_) {
    store.dispatch(DecrementAction());
  });

  querySelector('#incrementIfOdd').onClick.listen((_) {
    if (store.state % 2 != 0) {
      store.dispatch(IncrementAction());
    }
  });

  querySelector('#incrementAsync').onClick.listen((_) {
    store.dispatch(IncrementAsyncAction());
  });
}
