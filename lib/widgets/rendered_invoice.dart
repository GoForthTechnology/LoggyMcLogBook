import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/currency.dart';
import 'package:lmlb/entities/invoice.dart';

const rightHeaderColumnWidth = 200.0;
const tableCellPadding = 5.0;
final formatter = DateFormat('d MMMM y');

class ClientInfo {
  final String clientDisplayNum;
  final String fullName;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String email;
  final String phoneNumber;

  ClientInfo(
      {required this.clientDisplayNum,
      required this.fullName,
      required this.address,
      required this.city,
      required this.state,
      required this.zip,
      required this.country,
      required this.email,
      required this.phoneNumber});
}

class RenderedInvoiceWidget extends StatelessWidget {
  final Invoice invoice;
  final ClientInfo clientInfo;

  const RenderedInvoiceWidget(
      {super.key, required this.invoice, required this.clientInfo});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(0),
        child: ConstrainedBox(
            constraints: const BoxConstraints(),
            child: Column(children: [
              const InvoiceHeaderWidget(),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BillToWidget(client: clientInfo),
                  const Spacer(),
                  InvoiceInfoWidget(clientInfo: clientInfo, invoice: invoice),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              EntryTableWidget(
                invoice: invoice,
              ),
              const SizedBox(
                height: 20,
              ),
              const InvoiceFooter(),
            ])));
  }
}

TableRow _createRow({
  required String label,
  required int quantity,
  required double price,
  required Currency currency,
}) {
  return TableRow(
    children: [
      ...[
        label,
        quantity.toString(),
        price.toString(),
        "$price ${currency.name}",
      ].mapIndexed((i, e) => Container(
            alignment: i == 0 ? Alignment.centerLeft : Alignment.center,
            padding: const EdgeInsets.all(tableCellPadding),
            child: Text(e),
          )),
    ],
  );
}

class EntryTableWidget extends StatelessWidget {
  final Invoice invoice;

  const EntryTableWidget({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    List<TableRow> appointmentRows = invoice.appointmentEntries
        .map((e) => _createRow(
              label:
                  "${e.appointmentType.prettyName()} on ${formatter.format(e.appointmentDate)}",
              quantity: 1,
              price: e.price.toDouble(),
              currency: invoice.currency,
            ))
        .toList();
    List<TableRow> materialsRows = invoice.materialOrderSummaries
        .map((s) {
          List<TableRow> rows = s.entries
              .map((e) => _createRow(
                    label: e.materialName,
                    quantity: e.quantity,
                    price: e.price.toDouble(),
                    currency: invoice.currency,
                  ))
              .toList();
          return rows;
        })
        .expand((e) => e)
        .toList();
    int total = invoice.appointmentEntries.map((e) => e.price).sum;
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FixedColumnWidth(100),
            2: FixedColumnWidth(100),
            3: FixedColumnWidth(100),
          },
          children: <TableRow>[
            TableRow(
                decoration: const BoxDecoration(
                    border: Border(
                  top: BorderSide(color: Colors.black, width: 1.0),
                  bottom: BorderSide(color: Colors.black, width: 1.0),
                )),
                children: [
                  ...[
                    "Description",
                    "Quantity",
                    "Price",
                    "Amount"
                  ].mapIndexed((i, e) => Container(
                        alignment:
                            i == 0 ? Alignment.centerLeft : Alignment.center,
                        padding: const EdgeInsets.all(tableCellPadding),
                        child: Text(
                          e,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                ]),
            ...appointmentRows,
            ...materialsRows,
            TableRow(
                decoration: const BoxDecoration(
                    border: Border(
                  top: BorderSide(color: Colors.black, width: 1.0),
                  bottom: BorderSide(color: Colors.black, width: 1.0),
                )),
                children: [
                  ...[
                    "",
                    "",
                    "Total",
                    "$total ${invoice.currency.name}"
                  ].mapIndexed((i, e) => Container(
                        alignment:
                            i == 0 ? Alignment.centerLeft : Alignment.center,
                        padding: const EdgeInsets.all(tableCellPadding),
                        child: Text(
                          e,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                ]),
          ],
        ));
  }
}

class InvoiceFooter extends StatelessWidget {
  const InvoiceFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          "Payment due 10 days from date issued",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        Text(""),
        Text(
            "Parker (Rachel) Roth | 2311 N Greenleaf St | Wichita, Kansas 67226 (USA)					"),
        Text("IBAN: GB17 REVO 0099 7022 7746 91"),
        Text("BIC: REVOGB21"),
        Text("Venmo: @Rachel-Roth-9"),
        Text("Paypal: Rachel.Weber.Roth@gmail.com"),
      ],
    );
  }
}

class InvoiceInfoWidget extends StatelessWidget {
  final ClientInfo clientInfo;
  final Invoice invoice;

  const InvoiceInfoWidget(
      {super.key, required this.clientInfo, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints:
            const BoxConstraints.tightFor(width: rightHeaderColumnWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Invoice: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(invoice.invoiceNumStr()),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Client: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(clientInfo.clientDisplayNum),
              ],
            ),
            const Text(""),
            Row(
              children: [
                const Text(
                  "Date: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(formatter.format(invoice.dateBilled!)),
              ],
            ),
          ],
        ));
  }
}

class BillToWidget extends StatelessWidget {
  final ClientInfo client;

  const BillToWidget({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bill To",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(client.fullName),
        Text(client.address),
        Text(
            "${client.city}, ${client.state} ${client.zip} (${client.country})"),
        Text(client.email),
        Text(client.phoneNumber),
      ],
    );
  }
}

class InvoiceHeaderWidget extends StatelessWidget {
  const InvoiceHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
            width: 200,
            height: 100,
            child: Image(image: AssetImage('images/bloom_logo.png'))),
        const Spacer(),
        ConstrainedBox(
            constraints:
                const BoxConstraints.tightFor(width: rightHeaderColumnWidth),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bloom Cycle Care",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Rachel Roth"),
                Text("2311 N Greenleaf St."),
                Text("Wichita, KS 67226 (USA)"),
                Text("rachel@bloomcyclecare.com"),
                Text("+1 316-226-0343"),
              ],
            )),
      ],
    );
  }
}
