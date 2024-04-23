import 'package:flutter/material.dart';
import 'package:lmlb/entities/child.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:provider/provider.dart';

class ReproductiveHistoryPanel extends StatelessWidget {
  final String clientID;

  const ReproductiveHistoryPanel({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return Consumer<Clients>(
      builder: (context, repo, child) => StreamBuilder(
        stream: repo.stream(clientID),
        builder: (context, snapshot) => ExpandableInfoPanel(
            title: "Reproductive History",
            subtitle: "",
            contents: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(flex: 1, child: ReproductiveCategoryColumn()),
                  Flexible(flex: 1, child: PregnancyColumn()),
                  Flexible(flex: 1, child: ChildrenColumn()),
                ],
              )
            ]),
      ),
    );
  }
}

class ReproductiveCategoryColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(
          "Reproductive History",
          style: Theme.of(context).textTheme.titleMedium,
        )),
        FakeReproductiveEntry(category: ReproductiveCategory.regular_cycles),
        FakeReproductiveEntry(category: ReproductiveCategory.pregnant),
        FakeReproductiveEntry(
            category: ReproductiveCategory.breastfeeding_total),
        FakeReproductiveEntry(category: ReproductiveCategory.long_cycles),
        FakeReproductiveEntry(category: ReproductiveCategory.infertility),
        FakeReproductiveEntry(category: ReproductiveCategory.pregnant),
        ElevatedButton(onPressed: () {}, child: Text("Update")),
      ],
    );
  }
}

class PregnancyColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(
          "Pregnancies",
          style: Theme.of(context).textTheme.titleMedium,
        )),
        FakePregnancy(subtitle: "Delivered Fake Baby #1", dueDate: "5/5/2002"),
        FakePregnancy(subtitle: "Miscarried", dueDate: "5/5/2008"),
        FakePregnancy(subtitle: "Delivered Fake Baby #2", dueDate: "5/5/2022"),
        ElevatedButton(onPressed: () {}, child: Text("Add Pregnancy")),
      ],
    );
  }
}

class ChildrenColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(
          "Children",
          style: Theme.of(context).textTheme.titleMedium,
        )),
        FakeBaby(name: "Fake Baby #1"),
        FakeBaby(name: "Fake Baby #2"),
        ElevatedButton(onPressed: () {}, child: Text("Add Child")),
      ],
    );
  }
}

class FakeBaby extends StatelessWidget {
  final String name;

  const FakeBaby({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(title: name, subtitle: "Age 6", contents: [
      TextFormField(
        initialValue: name,
        decoration: InputDecoration(label: Text("Name")),
      ),
      TextFormField(
        initialValue: "Nov 6, 2006",
        decoration: InputDecoration(label: Text("Date of Birth")),
      ),
      Center(child: TextButton(onPressed: () {}, child: Text("REMOVE"))),
    ]);
  }
}

class FakePregnancy extends StatelessWidget {
  final String dueDate;
  final String subtitle;

  const FakePregnancy(
      {super.key, required this.subtitle, required this.dueDate});

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
        title: "Due Date $dueDate",
        subtitle: subtitle,
        contents: [
          TextFormField(
            initialValue: dueDate,
            decoration: InputDecoration(label: Text("Due Date")),
          ),
          Row(
            children: [
              Text("Miscarrage?"),
              Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),
          Center(child: TextButton(onPressed: () {}, child: Text("REMOVE"))),
        ]);
  }
}

class FakeReproductiveEntry extends StatelessWidget {
  final ReproductiveCategory category;

  const FakeReproductiveEntry({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
        title: category.toString().split(".").last,
        subtitle: "Since 5/5/2022",
        contents: [
          TextFormField(
            initialValue: "5/5/2022",
            decoration: InputDecoration(label: Text("Starting Date")),
          ),
          Center(child: TextButton(onPressed: () {}, child: Text("REMOVE"))),
        ]);
  }
}
