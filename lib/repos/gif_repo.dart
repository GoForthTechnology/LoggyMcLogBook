import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:lmlb/entities/client_general_info.dart';

class FormKey {
  final String formID;
  final String clientID;

  FormKey({required this.formID, required this.clientID});
}

class FormValue<E> {
  final String value;
  final List<E> extras;

  FormValue({required this.value, required this.extras});
}

abstract class StreamingFormCrud<E> {

  Stream<FormValue<E>> getValue(FormKey key, Enum itemID);

  Stream<Map<String, FormValue<E>>> getAllValues(FormKey key);

  Future<void> updateValue(FormKey key, Enum itemID, FormValue<E> value);

  Future<void> updateAllValues(FormKey key, Map<String, FormValue<E>> values);
}

class FirebaseFormCrud<E> extends StreamingFormCrud<E> {
  static const formRoot = "forms";
  static const valueKey = "value";
  static const extrasKey = "extras";

  final FirebaseDatabase db;
  final List<E> Function(Map<String, dynamic>) parseExtras;
  final List<Map<String, dynamic>> Function(List<E>) serializeExtras;
  final userCompleter = new Completer<User>();

  FirebaseFormCrud({required this.parseExtras, required this.serializeExtras})
      : db = FirebaseDatabase.instance {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((user) {
      if (user != null && !userCompleter.isCompleted) {
        userCompleter.complete(user);
      }
    });
  }

  Future<DatabaseReference> _formRef(FormKey key) async {
    var user = await userCompleter.future;
    return db.ref("$formRoot/${key.formID}/${user.uid}/${key.clientID}");
  }

  Future<DatabaseReference> _itemRef(FormKey key, Enum itemID) async {
    var formRef = await _formRef(key);
    return formRef.child(itemID.name);
  }

  FormValue<E> _parseValue(Map<String, dynamic> json) {
    var value = json[valueKey];
    Map<String, dynamic> extrasMap = {};
    if (json.containsKey(extrasKey)) {
      extrasMap = json[extrasKey];
    }
    return FormValue(value: value, extras: parseExtras(extrasMap));
  }

  @override
  Stream<FormValue<E>> getValue(FormKey key, Enum itemID) async* {
    var ref = await _itemRef(key, itemID);
    yield* ref.onValue
        .map((e) => e.snapshot.value as Map<String, dynamic>)
        .map(_parseValue);
  }

  @override
  Stream<Map<String, FormValue<E>>> getAllValues(FormKey key) async* {
    var ref = await _formRef(key);
    yield* ref.onValue
        .map((e) {
          if (e.snapshot.exists) {
            return e.snapshot.value as Map<String, dynamic>;
          }
          return {};
        })
        .map((m) => m.map((k, v) => MapEntry(k, _parseValue(v))));
  }

  @override
  Future<void> updateValue(FormKey key, Enum itemID, FormValue<E> value) async {
    var ref = await _itemRef(key, itemID);
    Map<String, dynamic> json = {};
    json[valueKey] = value.value;
    json[extrasKey] = serializeExtras(value.extras);
    ref.set(json);
  }

  @override
  Future<void> updateAllValues(FormKey key, Map<String, FormValue<E>> values) async {
    var ref = await _formRef(key);
    Map<String, dynamic> json = {};
    for (var e in values.entries) {
      json[e.key] = {
        valueKey: e.value.value,
        extrasKey: serializeExtras(e.value.extras),
      };
    }
    await ref.set(json);
  }
}

class GifRepo extends ChangeNotifier {
  final StreamingFormCrud<void> _persistence;
  static const  Map<Type, String> _formIDs = {
    GeneralInfoItem: "GIF-1",
    DemographicInfoItem: "GIF-2",
    PregnancyHistoryItem: "GIF-3",
  };

  GifRepo(this._persistence);

  String _formID(Type enumType) {
    var formID = _formIDs[enumType];
    if (formID == null) {
      throw Exception("No form ID for type ${enumType.toString()}");
    }
    return formID;
  }

  Stream<Map<String, String>> getAll(Type enumType, String clientID) async* {
    var formID = _formID(enumType);
    var formKey = FormKey(formID: formID, clientID: clientID);
    yield* _persistence.getAllValues(formKey)
        .map((m) => m.map((k, v) => MapEntry(k, v.value)));
  }

  Future<void> updateAll(Type enumType, String clientID, Map<String, String> entries) async {
    var formID = _formID(enumType);
    var formKey = FormKey(formID: formID, clientID: clientID);
    var values = entries.map((k, v) => MapEntry(k, FormValue<void>(value: v, extras: [])));
    await _persistence.updateAllValues(formKey, values);
  }
}