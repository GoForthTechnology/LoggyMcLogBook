import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:lmlb/entities/client_general_info.dart';

class FormKey {
  final String formID;
  final String clientID;

  FormKey({required this.formID, required this.clientID});
}

class FormValue {
  final String value;
  final String comment;

  FormValue({required this.value, this.comment = ""});
}

abstract class StreamingFormCrud {
  Stream<FormValue> getValue(FormKey key, Enum itemID);

  Stream<Map<String, FormValue>> getAllValues(FormKey key);

  Future<void> updateValue(FormKey key, Enum itemID, FormValue value);

  Future<void> updateAllValues(FormKey key, Map<String, FormValue> values);
}

class FirestoreFormCrud<E> extends StreamingFormCrud {
  final FirebaseFirestore db;
  final userCompleter = new Completer<User>();

  FirestoreFormCrud() : db = FirebaseFirestore.instance {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !userCompleter.isCompleted) {
        userCompleter.complete(user);
      }
    });
  }

  Future<CollectionReference<FormValue>> _formReference(FormKey key) async {
    var user = await userCompleter.future.timeout(Duration(seconds: 10));
    return db
        .collection("users")
        .doc(user.uid)
        .collection("clients")
        .doc(key.clientID)
        .collection(key.formID)
        .withConverter<FormValue>(
          fromFirestore: (snapshot, _) {
            var data = snapshot.data()!;
            return FormValue(value: data["value"], comment: data["comment"]);
          },
          toFirestore: (value, _) => {
            "value": value.value,
            "comment": value.comment,
          },
        );
  }

  @override
  Stream<FormValue> getValue(FormKey key, Enum itemID) async* {
    var ref = await _formReference(key);
    yield* ref.doc(itemID.name).snapshots().map((snapshot) => snapshot.data()!);
  }

  @override
  Stream<Map<String, FormValue>> getAllValues(FormKey key) async* {
    var ref = await _formReference(key);
    yield* ref.snapshots().map((snapshot) {
      Map<String, FormValue> out = {};
      snapshot.docs.forEach((doc) {
        out.putIfAbsent(doc.id, () => doc.data());
      });
      return out;
    });
  }

  @override
  Future<void> updateAllValues(
      FormKey key, Map<String, FormValue> values) async {
    var ref = await _formReference(key);
    var futures = <Future>[];
    values.forEach((key, value) {
      futures.add(ref
          .doc(key)
          .set(value)
          .onError((error, stackTrace) => print("FOO: $error")));
    });
    await futures;
  }

  @override
  Future<void> updateValue(FormKey key, Enum itemID, FormValue value) async {
    var ref = await _formReference(key);
    await ref.doc(itemID.name).set(value);
  }
}

class FirebaseFormCrud<E> extends StreamingFormCrud {
  static const formRoot = "forms";
  static const valueKey = "value";
  static const commentKey = "comment";

  final FirebaseDatabase db;
  final userCompleter = new Completer<User>();

  FirebaseFormCrud() : db = FirebaseDatabase.instance {
    FirebaseAuth.instance.authStateChanges().listen((user) {
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

  FormValue _parseValue(Map<String, dynamic> json) {
    var value = json[valueKey];
    var comment = "";
    if (json.containsKey(commentKey)) {
      comment = json[commentKey];
    }
    return FormValue(value: value, comment: comment);
  }

  @override
  Stream<FormValue> getValue(FormKey key, Enum itemID) async* {
    var ref = await _itemRef(key, itemID);
    yield* ref.onValue
        .map((e) => e.snapshot.value as Map<String, dynamic>)
        .map(_parseValue);
  }

  @override
  Stream<Map<String, FormValue>> getAllValues(FormKey key) async* {
    var ref = await _formRef(key);
    yield* ref.onValue.map((e) {
      if (e.snapshot.exists) {
        return e.snapshot.value as Map<String, dynamic>;
      }
      return {};
    }).map((m) => m.map((k, v) => MapEntry(k, _parseValue(v))));
  }

  @override
  Future<void> updateValue(FormKey key, Enum itemID, FormValue value) async {
    var ref = await _itemRef(key, itemID);
    Map<String, dynamic> json = {};
    json[valueKey] = value.value;
    json[commentKey] = value.comment;
    ref.set(json);
  }

  @override
  Future<void> updateAllValues(
      FormKey key, Map<String, FormValue> values) async {
    var ref = await _formRef(key);
    Map<String, dynamic> json = {};
    for (var e in values.entries) {
      json[e.key] = {
        valueKey: e.value.value,
        commentKey: e.value.comment,
      };
    }
    await ref.set(json);
  }
}

class ItemConfig {
  final String formID;
  final List<GifItem> items;

  const ItemConfig({required this.formID, required this.items});
}

class GifRepo extends ChangeNotifier {
  final StreamingFormCrud _persistence;
  static const Map<Type, ItemConfig> _itemConfigs = {
    GeneralInfoItem: ItemConfig(
      formID: "GIF-GENERAL-INFO",
      items: GeneralInfoItem.values,
    ),
    DemographicInfoItem: ItemConfig(
      formID: "GIF-DEMOGRAPHIC-INFO",
      items: DemographicInfoItem.values,
    ),
    PregnancyHistoryItem: ItemConfig(
      formID: "GIF-PREGNANCY-HIST",
      items: PregnancyHistoryItem.values,
    ),
    MedicalHistoryItem: ItemConfig(
      formID: "GIF-MED-HIST",
      items: MedicalHistoryItem.values,
    ),
    FamilyPlanningHistoryItem: ItemConfig(
      formID: "GIF-FAMPLAN-HIST",
      items: FamilyPlanningHistoryItem.values,
    ),
  };

  GifRepo(this._persistence);

  String _formID(Type enumType) {
    var config = _itemConfigs[enumType];
    if (config == null) {
      throw Exception("No form ID for type ${enumType.toString()}");
    }
    return config.formID;
  }

  FormKey _formKey(Type enumType, String clientID) {
    return FormKey(formID: _formID(enumType), clientID: clientID);
  }

  Stream<Map<GifItem, String>> getAll(Type enumType, String clientID) async* {
    print("asdf");
    var itemConfig = _itemConfigs[enumType];
    if (itemConfig == null) {
      throw Exception("Could not find ItemConfig for $enumType");
    }
    Map<String, GifItem> index = {};
    itemConfig.items
        .forEach((item) => index.putIfAbsent(item.name, () => item));
    var formKey = _formKey(enumType, clientID);
    yield* _persistence.getAllValues(formKey).map((m) {
      Map<GifItem, String> out = {};
      m.forEach((k, v) {
        var item = index[k];
        if (item == null) {
        } else {
          out.putIfAbsent(item, () => v.value);
        }
      });
      return out;
    });
  }

  Future<void> updateAll(
      Type enumType, String clientID, Map<String, String> entries) async {
    var formKey = _formKey(enumType, clientID);
    var values = entries.map((k, v) => MapEntry(k, FormValue(value: v)));
    await _persistence.updateAllValues(formKey, values);
  }

  Stream<Map<GifItem, String>> explanations(
      Type enumType, String clientID) async* {
    yield* getAll(enumType, clientID).map((values) {
      Map<GifItem, String> explanations = {};
      values.forEach((item, value) {
        for (var option in item.explainOptions) {
          if (value == option.name) {
            explanations[item] = "";
          }
        }
      });
      return explanations;
    });
  }
}
