import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

part 'pregnancy.g.dart';

@JsonSerializable(explicitToJson: true)
class Pregnancy extends Indexable<Pregnancy> {
  final String? id;
  final DateTime dueDate;
  final DateTime? dateOfLoss;
  final DateTime? dateOfFirstMenses;
  final DateTime? dateOfDelivery;
  final String? note;

  Pregnancy(
      {required this.dueDate,
      this.note,
      this.id,
      this.dateOfLoss,
      this.dateOfFirstMenses,
      this.dateOfDelivery});

  Pregnancy copyWith({
    String? id,
    DateTime? dateOfLoss,
    DateTime? dateOfFirstMenses,
    DateTime? dateOfDelivery,
    String? note,
  }) {
    return Pregnancy(
      id: id ?? this.id,
      dueDate: dueDate,
      note: note ?? this.note,
      dateOfLoss: dateOfLoss ?? this.dateOfLoss,
      dateOfFirstMenses: dateOfFirstMenses ?? this.dateOfFirstMenses,
      dateOfDelivery: dateOfDelivery ?? this.dateOfDelivery,
    );
  }

  factory Pregnancy.fromJson(Map<String, dynamic> json) =>
      _$PregnancyFromJson(json);
  Map<String, dynamic> toJson() => _$PregnancyToJson(this);

  @override
  String? getId() {
    return id;
  }

  @override
  Pregnancy setId(String id) {
    return copyWith(id: id);
  }
}
