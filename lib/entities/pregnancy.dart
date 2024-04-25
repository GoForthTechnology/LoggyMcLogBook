import 'package:json_annotation/json_annotation.dart';

part 'pregnancy.g.dart';

@JsonSerializable(explicitToJson: true)
class Pregnancy {
  final DateTime dueDate;
  final DateTime? dateOfLoss;
  final DateTime? dateOfFirstMenses;
  final DateTime? dateOfDelivery;
  final String? note;

  Pregnancy(
      {required this.dueDate,
      this.note,
      this.dateOfLoss,
      this.dateOfFirstMenses,
      this.dateOfDelivery});

  Pregnancy copyWith({
    DateTime? dateOfLoss,
    DateTime? dateOfFirstMenses,
    DateTime? dateOfDelivery,
    String? note,
  }) {
    return Pregnancy(
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
}
