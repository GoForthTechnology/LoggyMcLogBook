import 'package:uuid/uuid.dart';
import 'package:lmlb/persistence/CrudInterface.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

class LocalCrud<T extends Indexable> extends CrudInterface<T> {
  final uuid = Uuid();
  final Map<String, T> _items = {};

  @override
  Future<T?> get(String id) {
    return Future.value(_items[id]);
  }

  @override
  Future<List<T>> getAll() {
    return Future.value(List.of(_items.values));
  }

  @override
  Future<String> insert(T item) {
    String id = uuid.v4();
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
    String? id = item.getId();
    if (id == null) {
      return insert(item);
    }
    _items[id] = item;
    return Future.value(null);
  }

  @override
  Future<void> init() async {
  }
}