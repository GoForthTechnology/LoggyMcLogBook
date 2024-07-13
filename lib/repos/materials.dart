import 'package:flutter/widgets.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class MaterialsRepo extends ChangeNotifier {
  final StreamingCrudInterface<MaterialItem> _materials;
  final StreamingCrudInterface<RestockOrder> _restockOrders;
  final StreamingCrudInterface<ClientOrder> _clientOrders;

  MaterialsRepo(this._materials, this._restockOrders, this._clientOrders);

  Stream<List<MaterialItem>> currentInventory() {
    return _materials.getAll();
  }

  Future<void> createItem(MaterialItem item) {
    return _materials.insert(item);
  }

  Future<void> updateItem(MaterialItem item) {
    return _materials.update(item);
  }

  Stream<List<RestockOrder>> restockOrders() {
    return _restockOrders.getAll();
  }

  Stream<List<ClientOrder>> clientOrders() {
    return _clientOrders.getAll();
  }

  Future<void> createRestockOrder(
      List<OrderEntry> entries, double shippingPrice) {
    return _restockOrders.insert(RestockOrder(
        dateReceived: null,
        entries: entries,
        shippingPrice: shippingPrice,
        dateCreated: DateTime.now()));
  }

  Future<void> updateRestockOrder(RestockOrder order) {
    return _restockOrders.update(order);
  }
}
