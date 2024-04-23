// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Child _$ChildFromJson(Map<String, dynamic> json) => Child(
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      dateOfDeath: json['dateOfDeath'] == null
          ? null
          : DateTime.parse(json['dateOfDeath'] as String),
    );

Map<String, dynamic> _$ChildToJson(Child instance) => <String, dynamic>{
      'name': instance.name,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'dateOfDeath': instance.dateOfDeath?.toIso8601String(),
    };
