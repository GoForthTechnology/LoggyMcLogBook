import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

import 'currency.dart';

part 'client.g.dart';

enum ClientStatus { Prospective, Active, Inactive }

@JsonSerializable(explicitToJson: true)
class Client extends Indexable<Client> {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;
  final String? uid;
  final int? num;
  final bool? active;
  final String firstName;
  final String lastName;
  final String practitionerID;
  final Currency? currency;
  final int? defaultFollowUpPrice;

  final List<ReproductiveCategoryEntry> reproductiveCategoryHistory;

  Client({
    required this.firstName,
    required this.lastName,
    required this.practitionerID,
    this.id,
    this.uid,
    this.num,
    this.active,
    this.reproductiveCategoryHistory = const [],
    this.currency,
    this.defaultFollowUpPrice,
  });

  Client copyWith({
    String? id,
    String? uid,
    int? num,
    bool? active,
    String? firstName,
    String? lastName,
    String? practitionerID,
    Currency? currency,
    int? defaultFollowUpPrice,
    List<ReproductiveCategoryEntry>? reproductiveCategoryHistory,
  }) {
    return Client(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      num: num ?? this.num,
      active: active ?? this.active,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      practitionerID: practitionerID ?? this.practitionerID,
      reproductiveCategoryHistory:
          reproductiveCategoryHistory ?? this.reproductiveCategoryHistory,
      defaultFollowUpPrice: defaultFollowUpPrice ?? this.defaultFollowUpPrice,
      currency: currency ?? this.currency,
    );
  }

  @override
  String toString() {
    return fullName();
  }

  @override
  String? getId() {
    return id;
  }

  ClientStatus status() {
    if (num == null) {
      return ClientStatus.Prospective;
    }
    if (active ?? false) {
      return ClientStatus.Active;
    }
    return ClientStatus.Inactive;
  }

  bool isActive() {
    return status() == ClientStatus.Active;
  }

  @override
  Client setId(String id) {
    return copyWith(id: id);
  }

  String fullName() {
    return "$firstName $lastName";
  }

  String? displayNum() {
    return num == null ? null : "0${num! + 10000}";
  }

  ReproductiveCategoryEntry? currentReproductiveCategory() {
    ReproductiveCategoryEntry? current;
    for (var entry in reproductiveCategoryHistory) {
      if (current == null || current.sinceDate.isBefore(entry.sinceDate)) {
        current = entry;
      }
    }
    return current;
  }

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);
}

class BillingInformation {
  final Currency? currency;

  BillingInformation({this.currency});
}

@JsonSerializable(explicitToJson: true)
class ReproductiveCategoryEntry extends Indexable<ReproductiveCategoryEntry> {
  final String? id;
  final ReproductiveCategory category;
  final DateTime sinceDate;
  final String? note;

  ReproductiveCategoryEntry(
      {required this.category, required this.sinceDate, this.note, this.id});

  ReproductiveCategoryEntry copyWith({String? id}) {
    return ReproductiveCategoryEntry(
      id: id ?? this.id,
      category: category,
      sinceDate: sinceDate,
    );
  }

  factory ReproductiveCategoryEntry.fromJson(Map<String, dynamic> json) =>
      _$ReproductiveCategoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$ReproductiveCategoryEntryToJson(this);

  @override
  String? getId() {
    return id;
  }

  @override
  ReproductiveCategoryEntry setId(String id) {
    return copyWith(id: id);
  }
}

enum ReproductiveCategory {
  regular_cycles,
  regular_cycles_sterilized,
  long_cycles,
  breastfeeding_total,
  breastfeeding_weaning,
  post_poll,
  premenopause,
  postpartum_not_breastfeeding,
  post_abortion,
  infertility,
  pregnant;

  @override
  String toString() {
    var words = name.split("_");
    for (int i = 0; i < words.length; i++) {
      var word = words[i];
      word = "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
      words[i] = word;
    }
    return words.join(" ");
  }

  String get code {
    switch (this) {
      case ReproductiveCategory.regular_cycles:
        return "1";
      case ReproductiveCategory.regular_cycles_sterilized:
        return "1s";
      case ReproductiveCategory.long_cycles:
        return "2";
      case ReproductiveCategory.breastfeeding_total:
        return "3";
      case ReproductiveCategory.breastfeeding_weaning:
        return "4";
      case ReproductiveCategory.post_poll:
        return "5";
      case ReproductiveCategory.premenopause:
        return "6";
      case ReproductiveCategory.postpartum_not_breastfeeding:
        return "7";
      case ReproductiveCategory.post_abortion:
        return "8";
      case ReproductiveCategory.infertility:
        return "9";
      case ReproductiveCategory.pregnant:
        return "10";
      default:
        throw Exception("Unknown code for $this");
    }
  }
}
