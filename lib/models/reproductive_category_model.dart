import 'package:flutter/material.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/persistence/firebase/firestore_subcollection_crud.dart';

class ReproductiveCategoryModel extends ChangeNotifier {
  final Map<String, List<ReproductiveCategoryEntry>> entryIndex = {};
  final _persistence = FireStoreSubcollectionCrud<ReproductiveCategoryEntry>(
    primaryCollectionName: "clients",
    subcollectionName: "reproductive_category",
    fromJson: (snapshot) =>
        ReproductiveCategoryEntry.fromJson(snapshot.data() ?? {})
            .setId(snapshot.id),
    toJson: (child) => child.toJson(),
  );

  Future<void> addEntry(
      String clientID, ReproductiveCategoryEntry entry) async {
    _persistence.addDoc(doc: entry, primaryDocID: clientID);
    notifyListeners();
  }

  Future<void> removeEntry(
      String clientID, ReproductiveCategoryEntry entry) async {
    _persistence.removeDoc(docID: entry.id!, primaryDocID: clientID);
    notifyListeners();
  }

  Stream<List<ReproductiveCategoryEntry>> entries(String clientID) async* {
    yield* _persistence.streamCollection(primaryDocID: clientID);
  }
}
