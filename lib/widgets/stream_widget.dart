import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class WidgetModel<S> extends ChangeNotifier {

  StreamController<S> stateController = new StreamController.broadcast();

  Stream<S> state() {
    return stateController.stream;
  }

  void updateState(S state) {
    stateController.add(state);
  }

  S initialState();

  void dispose() {
    super.dispose();
    stateController.close();
  }
}

abstract class StreamWidget<M extends WidgetModel<S>, S> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var streamProvider = (M model) => StreamProvider<S>.value(
      value: model.state(),
      initialData: model.initialState(),
      builder: (context, child) => Consumer<S>(
          builder: (context, state, child) => render(context, state, model),
      ),
    );
    return Consumer<M>(builder: (context, model, child) => streamProvider(model));
  }

  Widget render(BuildContext context, S state, M model);
}
