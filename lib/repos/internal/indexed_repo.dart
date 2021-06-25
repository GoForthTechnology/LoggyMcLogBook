
import 'package:flutter/foundation.dart';

abstract class IndexedRepo<K, T> extends ChangeNotifier {
  Map<K, List<T>> _index = {};
  K Function(T) _keyExtractor;
  void Function(T, K) _setPrimaryKey;
  bool Function(T, T) _primaryKeysEqual;
  int Function(T, T) _compare;

  IndexedRepo(this._keyExtractor, this._setPrimaryKey, this._primaryKeysEqual, this._compare);

  Future<void> initIndex(Future<List<T>> initialValues) {
    return initialValues.then((values) {
      values.forEach((value) {
        K key = _keyExtractor(value);
        if (_index.containsKey(key)) {
          _index[key]!.add(value);
        } else {
          _index[key] = [value];
        }
      });
      notifyListeners();
    });
  }

  List<T> getFromIndex({K? keyFilter, bool? sorted, bool Function(T)? predicate}) {
    final List<T> values = [];
    if (keyFilter != null && _index.containsKey(keyFilter)) {
      values.addAll(_index[keyFilter]!);
    } else {
      values.addAll(_index.values.expand((a) => a).toList());
    }
    if (predicate != null) {
      List<T> filteredValues = [];
      values.forEach((value) {
        if (predicate(value)) {
          filteredValues.add(value);
        }
      });
      values.clear();
      values.addAll(filteredValues);
    }
    if (sorted != null && sorted) {
      values.sort(_compare);
    }
    return values;
  }

  Future<void> addToIndex(T value, Future<K> insert) {
    return insert.then((key) {
      _setPrimaryKey(value, key);
      var values = getFromIndex(keyFilter: key);
      if (values == null) {
        _index[key] = [value];
      } else {
        _index[key]!.add(value);
      }
      notifyListeners();
    });
  }

  Future<void> updateIndex(T value, Future<int> update) {
    return update.then((numUpdated) {
      if (numUpdated == 0) {
        return Future.error("No appointment updated in DB");
      }
      var values = _index[_keyExtractor(value)];
      if (values != null) {
        for (int i=0; i<values.length; i++) {
          if (_primaryKeysEqual(values[i], value)) {
            values.removeAt(i);
            values.add(value);
            notifyListeners();
            return null;
          }
        }
      }
      return Future.error("Appointment not found");
    });
  }

  Future<void> removeFromIndex(T value, Future<int> removal) {
    return removal.then((numRemoved) {
      if (numRemoved == 0) {
        return Future.error("Removal op failed");
      }
      if (!_index[_keyExtractor(value)]!.remove(value)) {
        return Future.error("Index removal failed");
      }
      notifyListeners();
    });
  }
}