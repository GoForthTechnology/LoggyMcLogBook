// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pregnancy _$PregnancyFromJson(Map<String, dynamic> json) => Pregnancy(
      dueDate: DateTime.parse(json['dueDate'] as String),
      note: json['note'] as String?,
      id: json['id'] as String?,
      dateOfLoss: json['dateOfLoss'] == null
          ? null
          : DateTime.parse(json['dateOfLoss'] as String),
      dateOfFirstMenses: json['dateOfFirstMenses'] == null
          ? null
          : DateTime.parse(json['dateOfFirstMenses'] as String),
      dateOfDelivery: json['dateOfDelivery'] == null
          ? null
          : DateTime.parse(json['dateOfDelivery'] as String),
    );

Map<String, dynamic> _$PregnancyToJson(Pregnancy instance) => <String, dynamic>{
      'id': instance.id,
      'dueDate': instance.dueDate.toIso8601String(),
      'dateOfLoss': instance.dateOfLoss?.toIso8601String(),
      'dateOfFirstMenses': instance.dateOfFirstMenses?.toIso8601String(),
      'dateOfDelivery': instance.dateOfDelivery?.toIso8601String(),
      'note': instance.note,
    };
