
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:lmlb/entities/client_general_info.dart';
import 'package:lmlb/repos/gif_repo.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:provider/provider.dart';

class ClientID extends ChangeNotifier {
  final String value;

  ClientID(this.value);
}

class GifSection {
  final String title;
  final Type enumType;
  final List<List<GifItem>> items;

  const GifSection({required this.title, required this.enumType, required this.items});
}

class GifForm extends StatelessWidget {
  final String clientID;

  const GifForm({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClientID>(create: (context) => ClientID(clientID), builder: (context, child) => ExpandableInfoPanel(
      title: "General Intake Form",
      subtitle: "Not yet completed",
      contents: sections.map((section) => GifFormSection(
        sectionTitle: section.title,
        enumType: section.enumType,
        itemRows: section.items,
      )).toList(),
    ));
  }
}

class GifStepper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GifStepperState();
}

class GifStepperState extends State<GifStepper> {
  Map<GifItem, TextEditingController> controllers = {};
  List<GlobalKey<FormState>> _formKeys = List
      .generate(sections.length, (index) => GlobalKey<FormState>());
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _index,
      onStepCancel: _cancelStep,
      onStepContinue: _continueStep,
      onStepTapped: _selectStep,
      steps: sections.mapIndexed(_step).toList(),
    );
  }

  Step _step(int index, GifSection section) {
    return Step(
      state: _stepState(index),
      title: Text(section.title),
      content: Form(key: _formKeys[index], child: Column(children: _rows(section),)),
    );
  }

  StepState _stepState(int index) {
    if (index == _index) {
      return StepState.editing;
    }
    if (index > _index) {
      return StepState.indexed;
    }
    var isValid = _formKeys[index].currentState?.validate() ?? false;
    return isValid ? StepState.complete : StepState.error;
  }

  List<Widget> _rows(GifSection section) {
    if (MediaQuery.of(context).size.width >= 720) {
      return section.items
          .map((row) => Row(children: row.map((item) => Expanded(child: _itemWidget(item))).toList()))
          .toList();
    }
    return section.items.expand((r) => r).map((item) => Row(children: [
      Flexible(child: ConstrainedBox(constraints: BoxConstraints(minWidth: 150), child:  _itemWidget(item))),
    ],)).toList();
  }

  Widget _itemWidget(GifItem item) {
    var initialValue = "";
    var controller = controllers.putIfAbsent(item, () => TextEditingController(text: initialValue));
    return ItemWidget(
      initialValue: initialValue,
      initialComment: "",
      controller: controller,
      item: item,
      editEnabled: true,
      onChange: () => setState(() {}),
      updateComment: (a, b) {},
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
    if (_index < sections.length) {
      var key = _formKeys[_index];
      print("FOO: ${key.currentState == null}");
      if (key.currentState?.validate() ?? false) {
        setState(() {
          _index += 1;
        });
      } else {
        print("foo");
      }
    }
  }

  void _selectStep(int index) {
    setState(() {
      _index = index;
    });
  }
}

class GifBody extends StatelessWidget {
  final String clientID;

  const GifBody({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClientID>(
      create: (context) => ClientID(clientID),
      builder: (context, child) => Column(children: sections.map((section) => GifFormSection(
        sectionTitle: section.title,
        itemRows: section.items,
        enumType: section.enumType,
      )).toList()),
    );
  }
}

const sections = [
  GifSection(
    title: "General Information",
    enumType: GeneralInfoItem,
    items: [
      [GeneralInfoItem.NAME_WOMAN, GeneralInfoItem.NAME_MAN],
      [GeneralInfoItem.DOB_WOMAN, GeneralInfoItem.DOB_MAN],
      [GeneralInfoItem.ADDRESS],
      [GeneralInfoItem.CITY, GeneralInfoItem.STATE, GeneralInfoItem.ZIP, GeneralInfoItem.COUNTRY],
      [GeneralInfoItem.EMAIL, GeneralInfoItem.PHONE],
    ],
  ),
  GifSection(
    title: "Demographic Information",
    enumType: DemographicInfoItem,
    items: [
      [DemographicInfoItem.AGE_WOMAN, DemographicInfoItem.AGE_MAN],
      [DemographicInfoItem.ETHNIC_BACKGROUND_WOMAN, DemographicInfoItem.ETHNIC_BACKGROUND_MAN],
      [DemographicInfoItem.RELIGION_WOMAN, DemographicInfoItem.RELIGION_MAN],
      [DemographicInfoItem.MARITAL_STATUS_WOMAN, DemographicInfoItem.MARITAL_STATUS_MAN],
      [DemographicInfoItem.COMPLETED_EDUCATION_WOMAN, DemographicInfoItem.COMPLETED_EDUCATION_MAN],
      [DemographicInfoItem.OCCUPATIONAL_STATUS_WOMAN, DemographicInfoItem.OCCUPATIONAL_STATUS_MAN],
      [DemographicInfoItem.NOW_EMPLOYED_WOMAN, DemographicInfoItem.NOW_EMPLOYED_MAN],
      [DemographicInfoItem.ANNUAL_COMBINED_INCOME, DemographicInfoItem.NUMBER_OF_PEOPLE_LIVING_IN_HOUSEHOLD],
    ],
  ),
  GifSection(
    title: "Pregnancy History",
    enumType: PregnancyHistoryItem,
    items: [
      [PregnancyHistoryItem.NUMBER_OF_PREGNANCIES, PregnancyHistoryItem.NUMBER_LIVE_BIRTHS],
      [PregnancyHistoryItem.NUMBER_STILLBORN, PregnancyHistoryItem.NUMBER_SPONTANEOUS_ABORTION],
      [PregnancyHistoryItem.NUMBER_INDUCED_ABORTION, PregnancyHistoryItem.NUMBER_NOW_LIVING],
      [PregnancyHistoryItem.WOMANS_AGE_AT_FIRST_PREGNANCY, PregnancyHistoryItem.DELIVERY_METHOD],
    ],
  ),
  GifSection(
    title: "Gyn History",
    enumType: MedicalHistoryItem,
    items: [
      [MedicalHistoryItem.CERVICITIS, MedicalHistoryItem.CERVICAL_TREATMENT],
      [MedicalHistoryItem.INFERTILITY_TREATMENT, MedicalHistoryItem.ENDOMETRIOSIS],
      [MedicalHistoryItem.PCOD, MedicalHistoryItem.PELVIC_INFECTION],
      [MedicalHistoryItem.PMS, MedicalHistoryItem.BREAST_SURGERY],
      [MedicalHistoryItem.GYN_SURGERY],
    ],
  ),
  GifSection(
    title: "Menstrual History",
    enumType: MedicalHistoryItem,
    items: [
      [MedicalHistoryItem.AGE_AT_FIRST_MENSTRUATION, MedicalHistoryItem.NATURE_OF_CYCLES],
      [MedicalHistoryItem.AVERAGE_LENGTH_OF_MENSTRUAL_FLOW, MedicalHistoryItem.MENSTRUAL_CRAMPS],
    ],
  ),
  GifSection(
    title: "General Medical History",
    enumType: MedicalHistoryItem,
    items: [
      [MedicalHistoryItem.HIGH_BLOOD_PRESSURE, MedicalHistoryItem.HEART_DISEASE],
      [MedicalHistoryItem.DIABETES, MedicalHistoryItem.CONVULSIONS],
      [MedicalHistoryItem.MIGRAINE_HEADACHES, MedicalHistoryItem.THYROID_PROBLEMS],
      [MedicalHistoryItem.CANCER, MedicalHistoryItem.URINARY_TRACT_INFECTION],
      [MedicalHistoryItem.VARICOSE_VEINS, MedicalHistoryItem.BLOOD_CLOTS],
      [MedicalHistoryItem.ANEMIA, MedicalHistoryItem.ALLERGIES],
      [MedicalHistoryItem.DRUG_ALLERGIES, MedicalHistoryItem.STDS],
      [MedicalHistoryItem.NON_GYN_SURGERY, MedicalHistoryItem.VAGINAL_INFECTIONS],
    ],
  ),
  GifSection(
    title: "FamilyPlanning History",
    enumType: MedicalHistoryItem,
    items: [
      [FamilyPlanningHistoryItem.FIRST_MOST_RECENT_METHOD, FamilyPlanningHistoryItem.SECOND_MOST_RECENT_METHOD],
      [FamilyPlanningHistoryItem.THIRD_MOST_RECENT_METHOD, FamilyPlanningHistoryItem.FOURTH_MOST_RECENT_METHOD],
    ],
  ),
];

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class GifFormSection extends StatelessWidget {
  final String sectionTitle;
  final List<List<GifItem>> itemRows;
  final Type enumType;
  final Map<int, Widget> rowSeparators;
  final bool initiallyExpanded;

  const GifFormSection({super.key, required this.sectionTitle, required this.itemRows, required this.enumType, this.rowSeparators = const {}, this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GifRepo, ClientID>(builder: (context, repo, clientID, child) => FormSection(
      sectionTitle: sectionTitle,
      itemRows: itemRows,
      rowSeparators: rowSeparators,
      initialValues: repo.getAll(enumType, clientID.value).first,
      initiallyExpanded: initiallyExpanded,
      explanations: Stream.value({}),
      //explanations: repo.explanations(enumType, clientID.value),
      onSave: (m) async {
        await repo.updateAll(enumType, clientID.value, m);
      },
    ));
  }
}

class FormSection extends StatefulWidget {
  final String sectionTitle;
  final List<List<GifItem>> itemRows;
  final Map<int, Widget> rowSeparators;
  final Future<Map<GifItem, String>> initialValues;
  final Stream<Map<GifItem, String>> explanations;
  final Function(Map<String, String>) onSave;
  final bool initiallyExpanded;

  FormSection({required this.sectionTitle, required this.itemRows, required this.initialValues, required this.onSave, required this.rowSeparators, this.initiallyExpanded = false, required this.explanations});

  @override
  State<StatefulWidget> createState() => FormSectionState();
}

class FormSectionState extends State<FormSection> {
  bool editEnabled = false;
  Map<GifItem, String> initialValues = {};
  Map<GifItem, TextEditingController> controllers = {};
  Map<GifItem, String> comments = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<GifItem, String>>(future: widget.initialValues, builder: (context, snapshot) {
      initialValues = snapshot.data ?? {};
      return StreamBuilder<Map<GifItem, String>>(
        stream: widget.explanations,
        builder: ((context, snapshot) {
          var explanations = snapshot.data ?? {};
          return ExpandableInfoPanel(
            title: widget.sectionTitle,
            subtitle: "",
            trailing: _trailingWidget(),
            contents: _rows(context, explanations),
            initiallyExpanded: widget.initiallyExpanded,
          );
        }),
      );
    });
  }

  void updateComment(GifItem item, String comment) {
    setState(() {
      comments[item] = comment;
    });
  }

  List<Widget> _rows(BuildContext context, Map<GifItem, String> explanations) {
    List<Widget> rows;
    if (MediaQuery.of(context).size.width >= 720) {
      rows = widget.itemRows
          .map((row) => Row(children: row.map((item) => Expanded(child: _itemWidget(item))).toList()))
          .toList();
    } else {
      rows = widget.itemRows.expand((r) => r).map((item) => Row(children: [
        Flexible(child: ConstrainedBox(constraints: BoxConstraints(minWidth: 150), child:  _itemWidget(item))),
      ],)).toList();
    }
    List<Widget> out = [];
    for (var i = 0; i < rows.length; i++) {
      var separator = widget.rowSeparators[i];
      if (separator != null) {
        out.add(separator);
      }
      out.add(rows[i]);
    }
    if (explanations.isNotEmpty) {
      out.add(Text("Additional Questions"));
      explanations.forEach((item, explanation) {
        out.add(TextFormField(
          decoration: InputDecoration(
            labelText: item.name,
          ),
          initialValue: explanation,
        ));
      });
    }
    return out;
  }

  Widget _itemWidget(GifItem item) {
    var initialValue = initialValues[item] ?? "";
    var controller = controllers.putIfAbsent(item, () => TextEditingController(text: initialValue));
    return ItemWidget(
      initialValue: initialValue,
      initialComment: comments[item] ?? "",
      controller: controller,
      item: item,
      editEnabled: editEnabled,
      onChange: () => setState(() {}),
      updateComment: updateComment,
    );
  }

  Widget _trailingWidget() {
    if (editEnabled) {
      return IconButton(onPressed: () => setState(() {
        editEnabled = false;
        Map<String, String> entries = {};
        for (var entry in controllers.entries) {
          entries[entry.key.name] = entry.value.text;
        }
        widget.onSave(entries);
      }), icon: Icon(Icons.save),);
    }
    return IconButton(onPressed: () => setState(() {
      editEnabled = true;
    }), icon: Icon(Icons.edit),);
  }
}

class ItemWidget extends StatefulWidget {
  final GifItem item;
  final String initialValue;
  final String initialComment;
  final TextEditingController controller;
  final bool editEnabled;
  final void Function() onChange;
  final void Function(GifItem, String) updateComment;

  const ItemWidget({super.key, required this.item, required this.initialValue, required this.controller, required this.editEnabled, required this.onChange, required this.updateComment, required this.initialComment});

  @override
  State<StatefulWidget> createState() => ItemWidgetState(previousValue: initialValue,);
}

class ItemWidgetState extends State<ItemWidget> {
  String previousValue;

  ItemWidgetState({required this.previousValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: inputWidget()),
          if (showCommonIcon()) IconButton(
            onPressed: showCommentDialog,
            icon: Icon(Icons.comment),
          ),
        ],
      ),
    );
  }

  Widget inputWidget() {
    var decoration = InputDecoration(
      labelText: widget.item.label,
    );
    var validator = (value) {
      if (value == null || value.isEmpty) {
        return "Value required!";
      }
      return null;
    };
    if (widget.item.optionsEnum != null) {
      return DropdownButtonFormField<String>(
        items: widget.item.optionsEnum!.map((v) => DropdownMenuItem<String>(
          child: Text(toBeginningOfSentenceCase(v.name.toString().replaceAll("_", " "))!),
          value: v.name,
        )).toList(),
        onChanged: widget.editEnabled ? onEnumUpdate : null,
        value: widget.initialValue.isEmpty ? null : widget.initialValue,
        validator: validator,
        decoration: decoration,
      );
    }
    if (widget.item.inputType == InputType.DATE_PICKER) {
      var prompt = () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: widget.controller.text.isEmpty ? null : DateTime.parse(widget.controller.text),
          firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            widget.controller.text = picked.toIso8601String();
          });
        }
      };
      return TextFormField(
        controller: widget.controller,
        onTap: prompt,
        decoration: decoration,
        validator: validator,
        onChanged: ((value) {
          try {
            // Check that the value is a valid date
            DateTime.parse(value);
          } catch (exception) {
            // For cases when someone accidentally types some input, clear it
            // and prompt as normal
            widget.controller.text = "";
            prompt();
          }
        }),
      );
    }
    return TextFormField(
    decoration: InputDecoration(
    labelText: widget.item.label,
    ),
    enabled: widget.editEnabled,
      controller: widget.controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Value required!";
        }
        return null;
      },
    );
  }

  bool showCommonIcon() {
    return widget.controller.text == "YES";
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => CommentDialog(
        initialComment: widget.initialComment,
        onSave: (comment) {
          widget.updateComment(widget.item, comment);
        },
      ),
    );
  }

  void onEnumUpdate(String? value) {
    if (previousValue != value) {
      widget.controller.text = value ?? "";
      widget.onChange();
      if (value == "YES") {
        showCommentDialog();
      }
    }
    setState(() {
      previousValue = value ?? "";
    });
  }
}

class CommentDialog extends StatefulWidget {
  final String initialComment;
  final Function(String) onSave;

  const CommentDialog({super.key, required this.onSave, required this.initialComment});

  @override
  State<StatefulWidget> createState() => CommentDialogState();
}

class CommentDialogState extends State<CommentDialog> {
  var controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.initialComment;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Additional Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Please provide some additional context"),
          TextFormField(
            controller: controller,
            maxLines: null,
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: Text("Cancel")),
        TextButton(onPressed: () {
          widget.onSave(controller.text);
          Navigator.of(context).pop();
        }, child: Text("Save")),
      ],
    );
  }
}
