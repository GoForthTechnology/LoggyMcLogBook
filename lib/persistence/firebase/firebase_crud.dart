
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

class FirebaseCrud<T extends Indexable> extends CrudInterface<T> {
  final String directory;
  final FirebaseDatabase db;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  User? user;

  FirebaseCrud({required this.directory, required this.fromJson, required this.toJson}) : db = FirebaseDatabase.instance {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((user) {
      this.user = user;
      notifyListeners();
    });
  }

  @override
  void reInit() {
  }

  String? _ref({String? id}) {
    if (user == null) {
      return null;
    }
    var ref = "$directory/${user!.uid}";
    if (id != null) {
      ref = "$ref/$id";
    }
    return ref;
  }

  @override
  Future<T?> get(String id) async {
    final ref = _ref(id: id);
    if (ref == null) {
      return null;
    }
    final snapshot = await db.ref(ref).get();
    final numChildren = snapshot.children.length;
    if (!snapshot.exists) {
      return null;
    }
    if (numChildren > 1) {
      throw Exception("Found $numChildren children for $ref");
    }
    final json = snapshot.children.first.value as Map<String, dynamic>;
    return fromJson(json);
  }

  @override
  Future<List<T>> getAll() async {
    final ref = _ref(id: null);
    if (ref == null) {
      return [];
    }
    final snapshot = await db.ref(ref).get();
    return snapshot.children.map((child) {
      print("$ref getAll() ${child.value}");
      final json = child.value as Map<String, dynamic>;
      return fromJson(json);
    }).toList();
  }

  @override
  Future<String> insert(T t) {
    var ref = _ref(id: null);
    var child = db.ref(ref).push();
    var id = child.key!;
    var ut = t.setId(id);
    return child.set(toJson(ut)).then((_) => id);
  }

  @override
  Future<void> remove(T t) {
    final id = t.getId();
    if (id == null) {
      throw Exception("Id cannot be null during removal: $t}");
    }
    return db.ref(_ref(id: id)).remove();
  }

  @override
  Future<void> update(T t) {
    if (t.getId() == null) {
      return insert(t).then((id) {
        t.setId(id);
        return t;
      });
    }
    return db.ref(_ref(id: t.getId())).set(toJson(t));
  }
}