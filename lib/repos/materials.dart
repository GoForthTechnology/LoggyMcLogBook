import 'package:flutter/widgets.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/persistence/StreamingCrudInterface.dart';

class MaterialsRepo extends ChangeNotifier {
  final StreamingCrudInterface<MaterialItem> _materials;
  final StreamingCrudInterface<Order> _replacementOrders;
  final StreamingCrudInterface<ClientOrder> _clientOrders;

  MaterialsRepo(this._materials, this._replacementOrders, this._clientOrders);

  Stream<List<MaterialItem>> currentInventory() {
    return _materials.getAll();
  }

  Future<void> createItem(MaterialItem item) {
    return _materials.insert(item);
  }

  Future<void> updateItem(MaterialItem item) {
    return _materials.update(item);
  }

  Stream<List<Order>> replacementOrders() {
    return _replacementOrders.getAll();
  }

  Stream<List<Order>> clientOrders() {
    return _clientOrders.getAll();
  }
}
