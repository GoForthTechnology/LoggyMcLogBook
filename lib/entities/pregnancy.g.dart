// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pregnancy _$PregnancyFromJson(Map<String, dynamic> json) => Pregnancy(
      childID: json['childID'] as String?,
      dueDate: DateTime.parse(json['dueDate'] as String),
      dateOfLoss: json['dateOfLoss'] == null
          ? null
          : DateTime.parse(json['dateOfLoss'] as String),
      dateOfFirstMenses: json['dateOfFirstMenses'] == null
          ? null
          : DateTime.parse(json['dateOfFirstMenses'] as String),
    );

Map<String, dynamic> _$PregnancyToJson(Pregnancy instance) => <String, dynamic>{
      'dueDate': instance.dueDate.toIso8601String(),
      'dateOfLoss': instance.dateOfLoss?.toIso8601String(),
      'dateOfFirstMenses': instance.dateOfFirstMenses?.toIso8601String(),
      'childID': instance.childID,
    };
