// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'materials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Material _$MaterialFromJson(Map<String, dynamic> json) => Material(
      language: $enumDecode(_$LanguageEnumMap, json['language']),
      defaultPrices: (json['defaultPrices'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry($enumDecode(_$CurrencyEnumMap, k), (e as num).toInt()),
      ),
      displayName: json['displayName'] as String,
    );

Map<String, dynamic> _$MaterialToJson(Material instance) => <String, dynamic>{
      'displayName': instance.displayName,
      'language': _$LanguageEnumMap[instance.language]!,
      'defaultPrices': instance.defaultPrices
          .map((k, e) => MapEntry(_$CurrencyEnumMap[k]!, e)),
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

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => OrderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingPrice: (json['shippingPrice'] as num).toInt(),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'shippingPrice': instance.shippingPrice,
    };

ClientOrder _$ClientOrderFromJson(Map<String, dynamic> json) => ClientOrder(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => OrderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingPrice: (json['shippingPrice'] as num).toInt(),
      clientID: json['clientID'] as String,
      invoiceID: json['invoiceID'] as String?,
    );

Map<String, dynamic> _$ClientOrderToJson(ClientOrder instance) =>
    <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'shippingPrice': instance.shippingPrice,
      'clientID': instance.clientID,
      'invoiceID': instance.invoiceID,
    };

OrderEntry _$OrderEntryFromJson(Map<String, dynamic> json) => OrderEntry(
      materialID: json['materialID'] as String,
      pricePerItem: (json['pricePerItem'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$OrderEntryToJson(OrderEntry instance) =>
    <String, dynamic>{
      'materialID': instance.materialID,
      'pricePerItem': instance.pricePerItem,
      'quantity': instance.quantity,
    };
