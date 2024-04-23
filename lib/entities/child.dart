import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

part 'child.g.dart';

@JsonSerializable(explicitToJson: true)
class Child extends Indexable<Child> {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;

  final String name;
  final DateTime dateOfBirth;
  final DateTime? dateOfDeath;

  Child(
      {this.id,
      required this.name,
      required this.dateOfBirth,
      this.dateOfDeath});

  Child copyWith({
    String? id,
    DateTime? dateOfBirth,
    DateTime? dateOfDeath,
  }) {
    return Child(
      id: id ?? this.id,
      name: name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfDeath: dateOfDeath ?? this.dateOfDeath,
    );
  }

  @override
  String? getId() {
    return id;
  }

  @override
  Child setId(String id) {
    return copyWith(id: id);
  }

  factory Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);
  Map<String, dynamic> toJson() => _$ChildToJson(this);
}
