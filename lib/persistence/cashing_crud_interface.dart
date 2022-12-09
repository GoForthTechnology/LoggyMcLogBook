import 'package:firebase_auth/firebase_auth.dart';
import 'package:lmlb/persistence/CrudInterface.dart';

import 'local/Indexable.dart';

class CachingCrudInterface<T extends Indexable<T>> extends CrudInterface<T> {
  final CrudInterface<T> _remote;
  Map<String, T> _cache = {};

  CachingCrudInterface(this._remote) {
    FirebaseAuth.instance.authStateChanges().listen((event) => init());
  }

  @override
  Future<void> init() async {
    _cache.clear();
    var ts = await _remote.getAll();
    return ts.forEach((t) => _cache[t.getId()!] = t);
  }

  @override
  Future<T?> get(String id) async {
    return _cache[id];
  }

  @override
  Future<List<T>> getAll() async {
    return _cache.values.toList();
  }

  @override
  Future<String> insert(T t) {
    return _remote.insert(t).then((id) {
      _cache[id] = t;
      return id;
    });
  }

  @override
  Future<void> remove(T t) {
    return _remote.remove(t).then((_) => _cache.remove(t.getId()));
  }

  @override
  Future<void> update(T t) {
    var id = t.getId();
    if (id == null) {
      return insert(t);
    }
    return _remote.update(t).then((_) => _cache[id] = t);
  }
}