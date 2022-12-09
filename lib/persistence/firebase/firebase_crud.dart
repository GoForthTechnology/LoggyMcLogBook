
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

class FirebaseCrud<T extends Indexable> extends CrudInterface<T> {
  final String directory;
  final FirebaseDatabase db;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final userCompleter = new Completer<User>();

  FirebaseCrud({required this.directory, required this.fromJson, required this.toJson}) : db = FirebaseDatabase.instance {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((user) {
          if (user != null) {
            userCompleter.complete(user);
            notifyListeners();
          }
    });
  }

  Future<String?> _ref({String? id}) async {
    var user = await userCompleter.future;
    var ref = "$directory/${user.uid}";
    if (id != null) {
      ref = "$ref/$id";
    }
    return ref;
  }

  @override
  Future<T?> get(String id) async {
    final ref = await _ref(id: id);
    final snapshot = await db.ref(ref).get();
    if (!snapshot.exists) {
      return null;
    }
    final json = snapshot.value as Map<String, dynamic>;
    return fromJson(json);
  }

  @override
  Future<List<T>> getAll() async {
    final ref = await _ref(id: null);
    final snapshot = await db.ref(ref).get();
    return snapshot.children.map((child) {
      final json = child.value as Map<String, dynamic>;
      return fromJson(json);
    }).toList();
  }

  @override
  Future<String> insert(T t) async {
    var ref = await _ref(id: null);
    var child = db.ref(ref).push();
    var id = child.key!;
    var ut = t.setId(id);
    return child.set(toJson(ut)).then((_) => id);
  }

  @override
  Future<void> remove(T t) async {
    final id = t.getId();
    if (id == null) {
      throw Exception("Id cannot be null during removal: $t}");
    }
    var ref = await _ref(id: id);
    return db.ref(ref).remove();
  }

  @override
  Future<void> update(T t) async {
    if (t.getId() == null) {
      return insert(t).then((id) {
        t.setId(id);
        return t;
      });
    }
    var ref = await _ref(id: t.getId());
    return db.ref(ref).set(toJson(t));
  }

  @override
  Future<void> init() async {}
}