import 'dart:async';
import 'package:lmlb/persistence/firebase/firestore_form_crud.dart';

abstract class StreamingFormCrudi<K> {
  Stream<FormValue> getValue(K key, Enum itemID);

  Stream<Map<String, FormValue>> getAllValues(K key);

  Future<void> updateValue(K key, Enum itemID, FormValue value);

  Future<void> updateAllValues(K key, Map<String, FormValue> values);
}
