import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lmlb/entities/materials.dart';
import 'package:lmlb/repos/materials.dart';
import 'package:lmlb/routes.gr.dart';

class NewClientOrderDialog extends StatefulWidget {
  final String clientID;
  final MaterialsRepo repo;
  final ClientOrder? order;
  final bool editingEnabled;

  const NewClientOrderDialog(
      {super.key,
      required this.repo,
      this.order,
      required this.clientID,
      required this.editingEnabled});

  @override
  State<NewClientOrderDialog> createState() => _NewClientOrderDialogState();
}

class _NewClientOrderDialogState extends State<NewClientOrderDialog> {
  final Map<String, TextEditingController> itemCounts = {};
  final Map<String, TextEditingController> itemPrices = {};
  final Map<String, String> displayNames = {};
  final shippingPriceController = TextEditingController();
  final dateShippedController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.order != null) {
      shippingPriceController.text = widget.order!.shippingPrice.toString();
      dateShippedController.text =
          widget.order!.dateShipped?.toIso8601String() ?? "";
      for (var entry in widget.order!.entries) {
        var countController = itemCounts.putIfAbsent(
            entry.materialID, () => TextEditingController());
        countController.text = entry.quantity.toString();

        var priceController = itemPrices.putIfAbsent(
            entry.materialID, () => TextEditingController());
        priceController.text = entry.pricePerItem.toString();
        displayNames[entry.materialID] = entry.displayName;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.order == null ? "New Order" : "Edit Order";
    return StreamBuilder<List<MaterialItem>>(
        stream: widget.repo.currentInventory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var items = snapshot.data!;
          var actions = widget.editingEnabled
              ? [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      var navigator = Navigator.of(context);
                      await _saveItem(items);
                      navigator.pop();
                    },
                    child: const Text("Save"),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ];
          return AlertDialog(
            title: Text(title),
            actions: actions,
            content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...items.map((i) => _itemControls(i)),
                    TextFormField(
                      enabled: widget.editingEnabled,
                      controller: shippingPriceController,
                      decoration: const InputDecoration(
                          labelText: "Shipping Price (USD)"),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      ],
                      validator: (value) =>
                          (value ?? "") == "" ? "Value Required!" : null,
                    ),
                    if (!widget.editingEnabled)
                      TextFormField(
                        enabled: false,
                        decoration:
                            const InputDecoration(labelText: "Date Shipped"),
                        initialValue:
                            widget.order?.dateShipped!.toIso8601String(),
                      ),
                    if (widget.order?.invoiceID != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: TextButton(
                            onPressed: () => AutoRouter.of(context).push(
                                InvoiceDetailScreenRoute(
                                    invoiceID: widget.order!.invoiceID!,
                                    clientID: widget.clientID)),
                            child: const Text("View Invoice"),
                          )),
                  ],
                )),
          );
        });
  }

  Widget _itemControls(MaterialItem item) {
    displayNames[item.id!] = item.displayName;
    return Row(
      children: [
        Text(item.displayName),
        const Spacer(),
        ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 60),
            child: TextFormField(
              enabled: widget.editingEnabled,
              controller: itemCounts.putIfAbsent(
                  item.id!, () => TextEditingController()),
              decoration: const InputDecoration(labelText: "Quantity"),
              validator: (v) =>
                  (v ?? "") == "" && (itemPrices[item.id!]?.text ?? "") != ""
                      ? "Value Required!"
                      : null,
            )),
        const SizedBox(width: 10),
        ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 60),
            child: TextFormField(
              enabled: widget.editingEnabled,
              controller: itemPrices.putIfAbsent(
                  item.id!, () => TextEditingController()),
              decoration: const InputDecoration(labelText: "Price"),
              validator: (v) =>
                  (v ?? "") == "" && (itemCounts[item.id!]?.text ?? "") != ""
                      ? "Value Required!"
                      : null,
            )),
      ],
    );
  }

  Future<void> _saveItem(List<MaterialItem> items) async {
    assert(widget.editingEnabled);

    if (formKey.currentState?.validate() ?? false) {
      var entries = itemCounts.entries
          .where((e) => itemCounts[e.key]!.text != "")
          .map((e) {
        var price = int.parse(itemPrices[e.key]!.text);
        var quantity = int.parse(itemCounts[e.key]!.text);
        var displayName = displayNames[e.key]!;
        return OrderEntry(
          materialID: e.key,
          pricePerItem: price,
          quantity: quantity,
          displayName: displayName,
        );
      }).toList();
      var shippingPrice = double.parse(shippingPriceController.text);

      if (widget.order == null) {
        await widget.repo
            .createClientOrder(widget.clientID, entries, shippingPrice);
      } else {
        await widget.repo.updateClientOrder(widget.order!.copyWith(
          entries: entries,
          shippingPrice: shippingPrice,
        ));
      }
    }
  }
}
