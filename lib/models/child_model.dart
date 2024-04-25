import 'package:flutter/material.dart';
import 'package:lmlb/entities/child.dart';

class ChildModel extends ChangeNotifier {
  final Map<String, List<Child>> childIndex = {};

  Future<void> addChild(String clientID, Child child) async {
    childIndex.putIfAbsent(clientID, () => []);
    childIndex[clientID]!.add(child);
    notifyListeners();
  }

  Future<void> removeChild(String clientID, Child child) async {
    childIndex[clientID]!.remove(child);
    notifyListeners();
  }

  Stream<List<Child>> children(String clientID) async* {
    yield childIndex[clientID] ?? [];
  }
}
