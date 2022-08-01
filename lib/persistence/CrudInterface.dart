abstract class CrudInterface<T> {
  Future<List<T>> getAll();

  Future<T?> get(int id);

  Future<int> insert(T appointment);

  Future<void> update(T appointment);

  Future<void> remove(T appointment);
}