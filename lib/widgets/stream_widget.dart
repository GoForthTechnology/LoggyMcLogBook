import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class WidgetModel<S> extends ChangeNotifier {
  StreamController<S> stateController = StreamController.broadcast();

  Stream<S> state() {
    return stateController.stream;
  }

  void updateState(S state) {
    stateController.add(state);
  }

  S initialState();

  @override
  void dispose() {
    super.dispose();
    stateController.close();
  }
}

abstract class StreamWidget<M extends WidgetModel<S>, S>
    extends StatelessWidget {
  const StreamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<M>(
        builder: (context, model, child) => createProvider(model));
  }

  StreamProvider<S> createProvider(M model) {
    return StreamProvider<S>.value(
      value: model.state(),
      initialData: model.initialState(),
      builder: (context, child) => Consumer<S>(
        builder: (context, state, child) => render(context, state, model),
      ),
    );
  }

  Widget render(BuildContext context, S state, M model);
}
