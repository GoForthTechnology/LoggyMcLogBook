import 'package:flutter/material.dart';
import 'package:lmlb/entities/child.dart';
import 'package:lmlb/persistence/firebase/firestore_subcollection_crud.dart';

class ChildModel extends ChangeNotifier {
  final _persistence = FireStoreSubcollectionCrud<Child>(
    primaryCollectionName: "clients",
    subcollectionName: "children",
    fromJson: (snapshot) =>
        Child.fromJson(snapshot.data() ?? {}).setId(snapshot.id),
    toJson: (child) => child.toJson(),
  );

  Future<void> addChild(String clientID, Child child) async {
    await _persistence.addDoc(doc: child, primaryDocID: clientID);
    notifyListeners();
  }

  Future<void> removeChild(String clientID, Child child) async {
    await _persistence.removeDoc(primaryDocID: clientID, docID: child.id!);
  }

  Stream<List<Child>> children(String clientID) async* {
    yield* _persistence.streamCollection(primaryDocID: clientID);
  }
}
