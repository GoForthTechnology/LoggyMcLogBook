import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';

class ReproductiveCategoryModel extends ChangeNotifier {
  final Map<String, List<ReproductiveCategoryEntry>> entryIndex = {};

  Future<void> addEntry(
      String clientID, ReproductiveCategoryEntry entry) async {
    entryIndex.putIfAbsent(clientID, () => []);
    entryIndex[clientID]!.add(entry);
    notifyListeners();
  }

  Future<void> removeEntry(
      String clientID, ReproductiveCategoryEntry entry) async {
    var entries = entryIndex[clientID];
    if (entries == null) {
      return;
    }
    entries.remove(entry);
    notifyListeners();
  }

  Stream<List<ReproductiveCategoryEntry>> entries(String clientID) async* {
    yield entryIndex[clientID] ?? [];
  }
}
