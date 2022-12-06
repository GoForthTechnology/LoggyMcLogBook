abstract class CrudInterface<T> {
  Future<List<T>> getAll();

  Future<T?> get(String id);

  Future<String> insert(T appointment);

  Future<void> update(T appointment);

  Future<void> remove(T appointment);
}