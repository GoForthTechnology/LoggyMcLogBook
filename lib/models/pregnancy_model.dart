import 'package:flutter/material.dart';
import 'package:lmlb/entities/pregnancy.dart';
import 'package:lmlb/persistence/firebase/firestore_subcollection_crud.dart';

class PregnancyModel extends ChangeNotifier {
  final _persistence = FireStoreSubcollectionCrud<Pregnancy>(
    primaryCollectionName: "clients",
    subcollectionName: "pregnancy",
    fromJson: (snapshot) =>
        Pregnancy.fromJson(snapshot.data() ?? {}).setId(snapshot.id),
    toJson: (child) => child.toJson(),
  );

  Future<void> addPregnancy(String clientID, Pregnancy pregnancy) async {
    _persistence.addDoc(doc: pregnancy, primaryDocID: clientID);
    notifyListeners();
  }

  Future<void> removePregnancy(String clientID, Pregnancy pregnancy) async {
    _persistence.removeDoc(primaryDocID: clientID, docID: pregnancy.id!);
    notifyListeners();
  }

  Stream<List<Pregnancy>> pregnancies(String clientID) async* {
    yield* _persistence.streamCollection(primaryDocID: clientID);
  }

  Future<int> numPregancies(String clientID) {
    return _persistence.collectionCount(primaryDocID: clientID);
  }
}
