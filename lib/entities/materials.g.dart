// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'materials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialItem _$MaterialItemFromJson(Map<String, dynamic> json) => MaterialItem(
      language: $enumDecode(_$LanguageEnumMap, json['language']),
      defaultPrices: (json['defaultPrices'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry($enumDecode(_$CurrencyEnumMap, k), (e as num).toInt()),
      ),
      displayName: json['displayName'] as String,
      currentQuantity: (json['currentQuantity'] as num).toInt(),
      reorderQuantity: (json['reorderQuantity'] as num).toInt(),
    );

Map<String, dynamic> _$MaterialItemToJson(MaterialItem instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'language': _$LanguageEnumMap[instance.language]!,
      'defaultPrices': instance.defaultPrices
          .map((k, e) => MapEntry(_$CurrencyEnumMap[k]!, e)),
      'currentQuantity': instance.currentQuantity,
      'reorderQuantity': instance.reorderQuantity,
    };

const _$LanguageEnumMap = {
  Language.english: 'english',
  Language.german: 'german',
};

const _$CurrencyEnumMap = {
  Currency.USD: 'USD',
  Currency.CHF: 'CHF',
  Currency.EUR: 'EUR',
  Currency.GBP: 'GBP',
};

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => OrderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingPrice: (json['shippingPrice'] as num).toDouble(),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'shippingPrice': instance.shippingPrice,
      'dateCreated': instance.dateCreated.toIso8601String(),
    };

RestockOrder _$RestockOrderFromJson(Map<String, dynamic> json) => RestockOrder(
      dateReceived: json['dateReceived'] == null
          ? null
          : DateTime.parse(json['dateReceived'] as String),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => OrderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingPrice: (json['shippingPrice'] as num).toDouble(),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );

Map<String, dynamic> _$RestockOrderToJson(RestockOrder instance) =>
    <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'shippingPrice': instance.shippingPrice,
      'dateCreated': instance.dateCreated.toIso8601String(),
      'dateReceived': instance.dateReceived?.toIso8601String(),
    };

ClientOrder _$ClientOrderFromJson(Map<String, dynamic> json) => ClientOrder(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => OrderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingPrice: (json['shippingPrice'] as num).toDouble(),
      invoiceID: json['invoiceID'] as String?,
      clientID: json['clientID'] as String,
      dateShipped: json['dateShipped'] == null
          ? null
          : DateTime.parse(json['dateShipped'] as String),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );

Map<String, dynamic> _$ClientOrderToJson(ClientOrder instance) =>
    <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'shippingPrice': instance.shippingPrice,
      'dateCreated': instance.dateCreated.toIso8601String(),
      'clientID': instance.clientID,
      'invoiceID': instance.invoiceID,
      'dateShipped': instance.dateShipped?.toIso8601String(),
    };

OrderEntry _$OrderEntryFromJson(Map<String, dynamic> json) => OrderEntry(
      materialID: json['materialID'] as String,
      displayName: json['displayName'] as String,
      pricePerItem: (json['pricePerItem'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$OrderEntryToJson(OrderEntry instance) =>
    <String, dynamic>{
      'materialID': instance.materialID,
      'displayName': instance.displayName,
      'pricePerItem': instance.pricePerItem,
      'quantity': instance.quantity,
    };
