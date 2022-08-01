import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

class LocalCrud<T extends Indexable> implements CrudInterface<T> {
  final Map<int, T> _items = {};

  @override
  Future<T?> get(int id) {
    return Future.value(_items[id]);
  }

  @override
  Future<List<T>> getAll() {
    return Future.value(List.of(_items.values));
  }

  @override
  Future<int> insert(T item) {
    int id = 1;
    if (_items.isNotEmpty) {
      List<int> keys = List.of(_items.keys);
      keys.sort((a,b) => a.compareTo(b));
      id = keys.last++;
    }
    T updatedItem = item.setId(id);
    _items[id] = updatedItem;
    return Future.value(id);
  }

  @override
  Future<void> remove(T item) {
    _items.remove(item);
    return Future.value(null);
  }

  @override
  Future<void> update(T item) {
    int? id = item.getId();
    if (id == null) {
      return insert(item);
    }
    _items[id] = item;
    return Future.value(null);
  }
}