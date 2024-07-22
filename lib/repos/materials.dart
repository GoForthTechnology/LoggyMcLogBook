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

  Stream<List<ClientOrder>> clientOrders(
      {String? clientID, String? invoiceID}) {
    List<Criteria> criteria = [];
    if (clientID != null) {
      criteria.add(Criteria("clientID", isEqualTo: clientID));
    }
    if (invoiceID != null) {
      criteria.add(Criteria("invoiceID", isEqualTo: invoiceID));
    }
    return _clientOrders.getWhere(criteria);
  }

  Future<void> createRestockOrder(
      List<OrderEntry> entries, double shippingPrice) {
    return _restockOrders.insert(RestockOrder(
        dateReceived: null,
        entries: entries,
        shippingPrice: shippingPrice,
        dateCreated: DateTime.now()));
  }

  Future<void> markRestockAsReceived(RestockOrder order) {
    List<Future<void>> futures = [];
    for (var entry in order.entries) {
      futures.add(_materials.get(entry.materialID).first.then((material) {
        return _materials.update(material!.copyWith(
            currentQuantity: material.currentQuantity + entry.quantity));
      }));
    }
    futures.add(
        _restockOrders.update(order.copyWith(dateReceived: DateTime.now())));
    return Future.wait(futures);
  }

  Future<void> updateRestockOrder(RestockOrder order) {
    return _restockOrders.update(order);
  }

  Future<void> createClientOrder(
      String clientID, List<OrderEntry> entries, double shippingPrice) {
    return _clientOrders.insert(ClientOrder(
        clientID: clientID,
        dateShipped: null,
        entries: entries,
        shippingPrice: shippingPrice,
        dateCreated: DateTime.now()));
  }

  Future<void> markClientOrderAsShipped(ClientOrder order) {
    List<Future<void>> futures = [];
    for (var entry in order.entries) {
      futures.add(_materials.get(entry.materialID).first.then((material) {
        return _materials.update(material!.copyWith(
            currentQuantity: material.currentQuantity - entry.quantity));
      }));
    }
    futures
        .add(_clientOrders.update(order.copyWith(dateShipped: DateTime.now())));
    return Future.wait(futures);
  }

  Future<void> updateClientOrder(ClientOrder order) {
    return _clientOrders.update(order);
  }

  Stream<ClientOrder?> getClientOrder(String orderID) {
    return _clientOrders.get(orderID);
  }
}
