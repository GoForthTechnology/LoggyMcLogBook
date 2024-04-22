import 'package:collection/collection.dart';
import 'package:fc_forms/fc_forms.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowUpFormStepper extends StatefulWidget {
  final int followUpNum;

  const FollowUpFormStepper({super.key, required this.followUpNum});

  @override
  State<StatefulWidget> createState() => FollowUpFormStepperState();
}

class FollowUpFormStepperState extends State<FollowUpFormStepper> {
  int _index = 0;
  late Map<int, List<FollowUpFormItem>> itemIndex;
  late Map<FollowUpFormEntryId, TextEditingController> inputs = {};
  late Map<FollowUpFormEntryId, TextEditingController> comments = {};

  @override
  void initState() {
    itemIndex = itemsForFollowUp(widget.followUpNum);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => FollowUpFormViewModel(),
        child: Stepper(
          currentStep: _index,
          onStepCancel: _cancelStep,
          onStepContinue: _continueStep,
          onStepTapped: _selectStep,
          steps: itemIndex.entries.map((e) => _step(e.key, e.value)).toList(),
        ));
  }

  Step _step(int sectionNum, List<FollowUpFormItem> items) {
    return Step(
      title: Text(sectionTitles[sectionNum] ?? "Section $sectionNum"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map(_item).toList(),
      ),
    );
  }

  Widget _item(FollowUpFormItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: item.questions
          .mapIndexed(
              (i, q) => _question(item.entryId(i, widget.followUpNum), item, q))
          .expand((element) => element)
          .toList(),
    );
  }

  List<Widget> _question(
      FollowUpFormEntryId id, FollowUpFormItem item, Question question) {
    List<Widget> inputWidgets = [
      ..._inputWidgets(id, question),
      IconButton(
          onPressed: () => _addComment(id), icon: Icon(Icons.add_comment))
    ];

    List<Widget> out = [
      Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text("${id.code} - ${question.description}"),
              Spacer(),
              ...inputWidgets,
            ],
          ))
    ];

    var comment = comments[id];
    if (comment != null) {
      out.add(TextFormField(
        decoration: InputDecoration(
          labelText: "Comment",
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _removeComment(id),
          ),
        ),
        controller: comment,
      ));
    }
    return out;
  }

  List<Widget> _inputWidgets(FollowUpFormEntryId id, Question question) {
    inputs.putIfAbsent(id, () => TextEditingController());
    if (question.acceptableInputs.isNotEmpty) {
      return question.acceptableInputs
          .map((input) => ElevatedButton(
              onPressed: () {
                if (input == "1") {
                  _addComment(id);
                }
              },
              child: Text(input)))
          .toList();
    }
    return [
      ElevatedButton(onPressed: () {}, child: Text("-")),
      Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text("0")),
      ElevatedButton(onPressed: () {}, child: Text("+")),
    ];
  }

  void _addComment(FollowUpFormEntryId id) {
    setState(() {
      comments[id] = TextEditingController();
    });
  }

  void _removeComment(FollowUpFormEntryId id) {
    setState(() {
      comments.remove(id);
    });
  }

  void _cancelStep() {
    if (_index > 0) {
      setState(() {
        _index -= 1;
      });
    }
  }

  void _continueStep() {
    if (_index < itemIndex.length) {
      // TODO: validate
      setState(() {
        _index += 1;
      });
    }
  }

  void _selectStep(int index) {
    setState(() {
      _index = index;
    });
  }
}
