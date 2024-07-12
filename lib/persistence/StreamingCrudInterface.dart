import 'package:flutter/cupertino.dart';

class Criteria {
  final Object field;
  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isGreaterThan;
  final Object? isLessThan;
  final bool? isNull;

  Criteria(this.field,
      {this.isEqualTo,
      this.isNotEqualTo,
      this.isNull,
      this.isGreaterThan,
      this.isLessThan});
}

abstract class StreamingCrudInterface<T> with ChangeNotifier {
  Stream<List<T>> getAll();

  Stream<T?> get(String id);

  Stream<List<T>> getWhere(List<Criteria> criteria);

  Future<String> insert(T t);

  Future<void> update(T t);

  Future<void> remove(String id);

  Future<void> init();
}
