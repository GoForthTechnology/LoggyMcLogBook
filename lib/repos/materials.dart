import 'package:flutter/widgets.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';

class MaterialsRepo extends ChangeNotifier {
  final Invoices _invoiceRepo;
  final Clients _clientRepo;
  final StreamingCrudInterface<MaterialItem> _materials;
  final StreamingCrudInterface<RestockOrder> _restockOrders;
  final StreamingCrudInterface<ClientOrder> _clientOrders;

  MaterialsRepo(this._materials, this._restockOrders, this._clientOrders,
      this._invoiceRepo, this._clientRepo);

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

  Stream<List<ClientOrder>> clientOrders({String? clientID}) {
    List<Criteria> criteria = [];
    if (clientID != null) {
      criteria.add(Criteria("clientID", isEqualTo: clientID));
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

  Future<String> invoiceClientOrder(ClientOrder order) async {
    if (order.invoiceID != null) {
      return "Order alreay invoiced!";
    }

    var pendingInvoice =
        await _invoiceRepo.getPending(clientID: order.clientID).first;
    if (pendingInvoice != null) {
      var materialOrderIDs = pendingInvoice.materialOrderIDs;
      await _invoiceRepo.update(pendingInvoice
          .copyWith(materialOrderIDs: [order.id!, ...materialOrderIDs]));
      await _clientOrders.update(order.copyWith(invoiceID: pendingInvoice.id));
      return "Added to pending invoice";
    }

    var client = await _clientRepo.get(order.clientID);
    if (client == null) {
      return "Could not find client!";
    }
    var invoiceID = await _invoiceRepo
        .create(client.id!, client, materialOrderIDs: [order.id!]);
    await _clientOrders.update(order.copyWith(invoiceID: invoiceID));
    return "Added to new invoice";
  }
}
