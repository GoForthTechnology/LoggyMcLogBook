import 'package:json_annotation/json_annotation.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/persistence/local/Indexable.dart';

part 'materials.g.dart';

enum Language {
  english,
  german;
}

@JsonSerializable(explicitToJson: true)
class MaterialItem implements Indexable<MaterialItem> {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;
  final String displayName;
  final Language language;
  final Map<Currency, int> defaultPrices;
  final int currentQuantity;
  final int reorderQuantity;

  MaterialItem(
      {required this.language,
      required this.defaultPrices,
      this.id,
      required this.displayName,
      required this.currentQuantity,
      required this.reorderQuantity});

  @override
  String? getId() {
    return id;
  }

  @override
  MaterialItem setId(String id) {
    return copyWith(id: id);
  }

  MaterialItem copyWith({
    String? id,
    String? displayName,
    Language? language,
    Map<Currency, int>? defaultPrices,
    int? currentQuantity,
    int? reorderQuantity,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      language: language ?? this.language,
      displayName: displayName ?? this.displayName,
      defaultPrices: defaultPrices ?? this.defaultPrices,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
    );
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) =>
      _$MaterialItemFromJson(json);
  Map<String, dynamic> toJson() => _$MaterialItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class _Order implements Indexable<_Order> {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;
  final List<OrderEntry> entries;
  final double shippingPrice;
  final DateTime dateCreated;

  _Order(
      {this.id,
      required this.entries,
      required this.shippingPrice,
      required this.dateCreated});

  @override
  String? getId() {
    return id;
  }

  @override
  _Order setId(String id) {
    return copyWith(id: id);
  }

  _Order copyWith(
      {String? id, List<OrderEntry>? entries, double? shippingPrice}) {
    return _Order(
      id: id ?? this.id,
      entries: entries ?? this.entries,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      dateCreated: dateCreated,
    );
  }

  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RestockOrder extends _Order {
  final DateTime? dateReceived;

  RestockOrder(
      {super.id,
      required this.dateReceived,
      required super.entries,
      required super.shippingPrice,
      required super.dateCreated});

  @override
  RestockOrder copyWith({
    String? id,
    List<OrderEntry>? entries,
    DateTime? dateReceived,
    double? shippingPrice,
  }) {
    return RestockOrder(
      id: id ?? this.id,
      entries: entries ?? this.entries,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      dateReceived: dateReceived ?? this.dateReceived,
      dateCreated: dateCreated,
    );
  }

  factory RestockOrder.fromJson(Map<String, dynamic> json) =>
      _$RestockOrderFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RestockOrderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ClientOrder extends _Order {
  final String clientID;
  final String? invoiceID;
  final DateTime? dateShipped;

  ClientOrder(
      {required super.entries,
      required super.shippingPrice,
      super.id,
      this.invoiceID,
      required this.clientID,
      required this.dateShipped,
      required super.dateCreated});

  @override
  ClientOrder copyWith(
      {String? id,
      List<OrderEntry>? entries,
      double? shippingPrice,
      DateTime? dateShipped,
      String? invoiceID}) {
    return ClientOrder(
      id: id ?? this.id,
      entries: entries ?? this.entries,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      dateCreated: dateCreated,
      dateShipped: dateShipped ?? this.dateShipped,
      clientID: clientID,
      invoiceID: invoiceID ?? this.invoiceID,
    );
  }

  factory ClientOrder.fromJson(Map<String, dynamic> json) =>
      _$ClientOrderFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ClientOrderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderEntry {
  final String materialID;
  final int pricePerItem;
  final int quantity;

  OrderEntry(
      {required this.materialID,
      required this.pricePerItem,
      required this.quantity});

  factory OrderEntry.fromJson(Map<String, dynamic> json) =>
      _$OrderEntryFromJson(json);
  Map<String, dynamic> toJson() => _$OrderEntryToJson(this);
}
