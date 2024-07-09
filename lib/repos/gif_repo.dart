import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lmlb/entities/client_general_info.dart';
import 'package:lmlb/persistence/firebase/firestore_form_crud.dart';
import 'package:lmlb/persistence/streaming_form_crud.dart';

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

  Stream<String> get(Enum foo, String clieentID) async* {
    var key = _formKey(foo.runtimeType, clieentID);
    yield* _persistence.getValue(key, foo).map((fv) => fv.value);
  }

  Stream<Map<GifItem, String>> getAll(Type enumType, String clientID) async* {
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
