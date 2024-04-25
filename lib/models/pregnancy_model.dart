import 'package:flutter/material.dart';
import 'package:lmlb/entities/pregnancy.dart';

class PregnancyModel extends ChangeNotifier {
  final Map<String, Map<DateTime, Pregnancy>> pregnancyIndex = {};

  Future<void> addPregnancy(String clientID, Pregnancy pregnancy) async {
    pregnancyIndex.putIfAbsent(clientID, () => {});
    pregnancyIndex[clientID]!.putIfAbsent(pregnancy.dueDate, () => pregnancy);
    notifyListeners();
  }

  Future<void> removePregnancy(String clientID, DateTime dueDate) async {
    var pregnancies = pregnancyIndex[clientID] ?? {};
    pregnancies.remove(dueDate);
    notifyListeners();
  }

  Stream<List<Pregnancy>> pregnancies(String clientID) async* {
    var pregnancies = pregnancyIndex[clientID] ?? {};
    yield pregnancies.values.toList();
  }
}
