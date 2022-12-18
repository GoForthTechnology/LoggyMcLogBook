import 'package:flutter/cupertino.dart';

abstract class StreamingCrudInterface<T> with ChangeNotifier {
  Stream<List<T>> getAll();

  Stream<T?> get(String id);

  Future<String> insert(T appointment);

  Future<void> update(T appointment);

  Future<void> remove(String id);

  Future<void> init();
}