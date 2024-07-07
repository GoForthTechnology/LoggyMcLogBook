// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      practitionerID: json['practitionerID'] as String,
      num: (json['num'] as num?)?.toInt(),
      active: json['active'] as bool?,
      reproductiveCategoryHistory: (json['reproductiveCategoryHistory']
                  as List<dynamic>?)
              ?.map((e) =>
                  ReproductiveCategoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currency: $enumDecodeNullable(_$CurrencyEnumMap, json['currency']),
      defaultFollowUpPrice: (json['defaultFollowUpPrice'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
      'num': instance.num,
      'active': instance.active,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'practitionerID': instance.practitionerID,
      'currency': _$CurrencyEnumMap[instance.currency],
      'defaultFollowUpPrice': instance.defaultFollowUpPrice,
      'reproductiveCategoryHistory':
          instance.reproductiveCategoryHistory.map((e) => e.toJson()).toList(),
    };

const _$CurrencyEnumMap = {
  Currency.USD: 'USD',
  Currency.CHF: 'CHF',
  Currency.EUR: 'EUR',
  Currency.GBP: 'GBP',
};

ReproductiveCategoryEntry _$ReproductiveCategoryEntryFromJson(
        Map<String, dynamic> json) =>
    ReproductiveCategoryEntry(
      category: $enumDecode(_$ReproductiveCategoryEnumMap, json['category']),
      sinceDate: DateTime.parse(json['sinceDate'] as String),
      note: json['note'] as String?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$ReproductiveCategoryEntryToJson(
        ReproductiveCategoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$ReproductiveCategoryEnumMap[instance.category]!,
      'sinceDate': instance.sinceDate.toIso8601String(),
      'note': instance.note,
    };

const _$ReproductiveCategoryEnumMap = {
  ReproductiveCategory.regular_cycles: 'regular_cycles',
  ReproductiveCategory.regular_cycles_sterilized: 'regular_cycles_sterilized',
  ReproductiveCategory.long_cycles: 'long_cycles',
  ReproductiveCategory.breastfeeding_total: 'breastfeeding_total',
  ReproductiveCategory.breastfeeding_weaning: 'breastfeeding_weaning',
  ReproductiveCategory.post_poll: 'post_poll',
  ReproductiveCategory.premenopause: 'premenopause',
  ReproductiveCategory.postpartum_not_breastfeeding:
      'postpartum_not_breastfeeding',
  ReproductiveCategory.post_abortion: 'post_abortion',
  ReproductiveCategory.infertility: 'infertility',
  ReproductiveCategory.pregnant: 'pregnant',
};
