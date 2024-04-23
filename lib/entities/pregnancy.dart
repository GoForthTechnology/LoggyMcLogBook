import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

part 'pregnancy.g.dart';

@JsonSerializable(explicitToJson: true)
class Pregnancy extends Indexable<Pregnancy> {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;

  final DateTime dueDate;
  final DateTime? dateOfLoss;
  final DateTime? dateOfFirstMenses;
  final String? childID;

  Pregnancy({
    this.id,
    this.childID,
    required this.dueDate,
    this.dateOfLoss,
    this.dateOfFirstMenses,
  });

  Pregnancy copyWith({
    String? id,
    String? childID,
    DateTime? dateOfLoss,
    DateTime? dateOfFirstMenses,
  }) {
    return Pregnancy(
      id: id ?? this.id,
      childID: childID ?? this.childID,
      dueDate: dueDate,
      dateOfLoss: dateOfLoss ?? this.dateOfLoss,
      dateOfFirstMenses: dateOfFirstMenses ?? this.dateOfFirstMenses,
    );
  }

  @override
  String? getId() {
    return id;
  }

  @override
  Pregnancy setId(String id) {
    return copyWith(id: id);
  }

  factory Pregnancy.fromJson(Map<String, dynamic> json) =>
      _$PregnancyFromJson(json);
  Map<String, dynamic> toJson() => _$PregnancyToJson(this);
}
