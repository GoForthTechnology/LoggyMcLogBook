import 'dart:async';
import 'package:lmlb/persistence/firebase/firestore_form_crud.dart';

abstract class StreamingFormCrud {
  Stream<FormValue> getValue(FormKey key, Enum itemID);

  Stream<Map<String, FormValue>> getAllValues(FormKey key);

  Future<void> updateValue(FormKey key, Enum itemID, FormValue value);

  Future<void> updateAllValues(FormKey key, Map<String, FormValue> values);
}
