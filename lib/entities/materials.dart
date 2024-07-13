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
class Order implements Indexable<Order> {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;
  final List<OrderEntry> entries;
  final int shippingPrice;

  Order({this.id, required this.entries, required this.shippingPrice});

  @override
  String? getId() {
    return id;
  }

  @override
  Order setId(String id) {
    return Order(id: id, entries: entries, shippingPrice: shippingPrice);
  }

  Order copyWith({String? id, List<OrderEntry>? entries, int? shippingPrice}) {
    return Order(
        id: id ?? this.id,
        entries: entries ?? this.entries,
        shippingPrice: shippingPrice ?? this.shippingPrice);
  }

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ClientOrder extends Order {
  final String clientID;
  final String? invoiceID;

  ClientOrder(
      {required super.entries,
      required super.shippingPrice,
      super.id,
      required this.clientID,
      this.invoiceID});

  @override
  ClientOrder copyWith(
      {String? id,
      List<OrderEntry>? entries,
      int? shippingPrice,
      String? invoiceID}) {
    return ClientOrder(
      id: id ?? this.id,
      entries: entries ?? this.entries,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      clientID: clientID,
      invoiceID: invoiceID ?? this.invoiceID,
    );
  }

  factory ClientOrder.fromJson(Map<String, dynamic> json) =>
      _$ClientOrderFromJson(json);
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
