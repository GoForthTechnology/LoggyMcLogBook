import 'package:collection/collection.dart';
import 'package:fc_forms/fc_forms.dart';
import 'package:flutter/material.dart';

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
    return Stepper(
      currentStep: _index,
      onStepCancel: _cancelStep,
      onStepContinue: _continueStep,
      onStepTapped: _selectStep,
      steps: itemIndex.entries.map((e) => _step(e.key, e.value)).toList(),
    );
  }

  Step _step(int sectionNum, List<FollowUpFormItem> items) {
    return Step(
      title: Text(sectionTitles[sectionNum] ?? "Section $sectionNum"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) {
              var subSectionTitleWidget = _subsectionTitleWidget(item.id());
              return [
                if (subSectionTitleWidget != null) subSectionTitleWidget,
                _item(item),
              ];
            })
            .expand((e) => e)
            .toList(),
      ),
    );
  }

  Widget? _subsectionTitleWidget(ItemId id) {
    var subSectionTitle = subSectionTitles[id];
    if (subSectionTitle == null) {
      return null;
    }
    return Text(
      subSectionTitle,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _item(FollowUpFormItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: item.questions
          .mapIndexed((i, q) => QuestionWidget(
              id: item.entryId(i, widget.followUpNum), item: item, question: q))
          .toList(),
    );
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

class QuestionWidget extends StatefulWidget {
  final FollowUpFormEntryId id;
  final FollowUpFormItem item;
  final Question question;

  const QuestionWidget(
      {super.key,
      required this.id,
      required this.item,
      required this.question});

  @override
  State<StatefulWidget> createState() => QuestionWidgetState();
}

class QuestionWidgetState extends State<QuestionWidget> {
  final TextEditingController inputController = TextEditingController();
  final Map<int, TextEditingController> commentControllers = {};
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> out = [
      Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text("${widget.id.code} - ${widget.question.description}"),
              SizedBox(
                width: 20,
              ),
              Spacer(),
              _inputWidgets(),
              IconButton(
                  onPressed: () => _addComment(),
                  icon: Icon(Icons.add_comment)),
              ...List.generate(
                  8,
                  (index) => Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(border: Border.all()),
                      )),
              IconButton(
                  onPressed:
                      commentControllers.isEmpty ? null : _toggleExpansion,
                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more)),
            ],
          ))
    ];
    if (expanded) {
      var comment = commentControllers[widget.id.followUpIndex];
      if (comment != null) {
        out.add(CommentWidget(
            onRemove: _removeComment,
            followUpNum: widget.id.followUpIndex + 1));
      }
    }
    return Column(
      children: out,
    );
  }

  void _toggleExpansion() {
    setState(() {
      expanded = !expanded;
    });
  }

  Widget _inputWidgets() {
    if (widget.question.acceptableInputs.isNotEmpty) {
      return ButtonRow(
        values: widget.question.acceptableInputs,
        onPressed: (value) {
          if (value == "1") {
            _addComment();
          }
        },
      );
    }
    return Row(children: [
      ElevatedButton(onPressed: () {}, child: Text("-")),
      Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text("0")),
      ElevatedButton(onPressed: () {}, child: Text("+")),
    ]);
  }

  void _addComment() {
    setState(() {
      commentControllers[widget.id.followUpIndex] = TextEditingController();
      expanded = true;
    });
  }

  void _removeComment() {
    setState(() {
      commentControllers.remove(widget.id.followUpIndex);
      if (commentControllers.isEmpty) {
        expanded = false;
      }
    });
  }
}

class CommentWidget extends StatelessWidget {
  final Function() onRemove;
  final int followUpNum;

  final commentController = TextEditingController();
  final planController = TextEditingController();

  CommentWidget({super.key, required this.onRemove, required this.followUpNum});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("#$followUpNum"),
        ),
        Expanded(
            child: TextFormField(
          controller: commentController,
          decoration: InputDecoration(
            label: Text("Comment"),
          ),
          maxLines: null,
        )),
        Expanded(
            child: TextFormField(
          controller: planController,
          decoration: InputDecoration(
            label: Text("Plan of Action"),
          ),
          maxLines: null,
        )),
        IconButton(onPressed: onRemove, icon: Icon(Icons.clear)),
      ],
    );
  }
}

class ButtonRow extends StatefulWidget {
  final Function(String?) onPressed;
  final List<String> values;

  const ButtonRow({super.key, required this.values, required this.onPressed});

  @override
  State<ButtonRow> createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  String? currentValue = null;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.values.map(_button).toList(),
    );
  }

  Widget _button(String value) {
    var onPressed = () {
      setState(() {
        if (currentValue == value) {
          currentValue = null;
        } else {
          currentValue = value;
        }
        widget.onPressed(currentValue);
      });
    };
    if (value == currentValue) {
      return FilledButton(onPressed: onPressed, child: Text(value));
    }
    return ElevatedButton(onPressed: onPressed, child: Text(value));
  }
}
