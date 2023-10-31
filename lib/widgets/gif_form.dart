
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lmlb/entities/client_general_info.dart';
import 'package:lmlb/repos/gif_repo.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:provider/provider.dart';

class ClientID extends ChangeNotifier {
  final String value;

  ClientID(this.value);
}

class GifForm extends StatelessWidget {
  final String clientID;

  const GifForm({super.key, required this.clientID});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClientID>(create: (context) => ClientID(clientID), builder: (context, child) => ExpandableInfoPanel(
      title: "General Intake Form",
      subtitle: "Not yet completed",
      contents: [
        GeneralInfoPanel(),
        DemographicInfoPanel(),
        PregnancyHistoryPanel(),
        ExpandableInfoPanel(
          title: "Medical History",
          subtitle: "",
          contents: [],
        ),
      ],
    ));
  }
}

class GeneralInfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GifFormSection(
      sectionTitle: "General Information",
      enumType: GeneralInfoItem,
      itemRows: [
        [GeneralInfoItem.NAME_WOMAN, GeneralInfoItem.NAME_MAN],
        [GeneralInfoItem.DOB_WOMAN, GeneralInfoItem.DOB_MAN],
        [GeneralInfoItem.ADDRESS],
        [GeneralInfoItem.CITY, GeneralInfoItem.STATE, GeneralInfoItem.ZIP, GeneralInfoItem.COUNTRY],
        [GeneralInfoItem.EMAIL, GeneralInfoItem.PHONE],
      ],
    );
  }
}

class DemographicInfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GifFormSection(
      sectionTitle: "Demographic Information",
      enumType: DemographicInfoItem,
      itemRows: [
        [DemographicInfoItem.AGE_WOMAN, DemographicInfoItem.AGE_MAN],
        [DemographicInfoItem.ETHNIC_BACKGROUND_WOMAN, DemographicInfoItem.ETHNIC_BACKGROUND_MAN],
        [DemographicInfoItem.RELIGION_WOMAN, DemographicInfoItem.RELIGION_MAN],
        [DemographicInfoItem.MARITAL_STATUS_WOMAN, DemographicInfoItem.MARITAL_STATUS_MAN],
        [DemographicInfoItem.COMPLETED_EDUCATION_WOMAN, DemographicInfoItem.COMPLETED_EDUCATION_MAN],
        [DemographicInfoItem.OCCUPATIONAL_STATUS_WOMAN, DemographicInfoItem.OCCUPATIONAL_STATUS_MAN],
        [DemographicInfoItem.NOW_EMPLOYED_WOMAN, DemographicInfoItem.NOW_EMPLOYED_MAN],
        [DemographicInfoItem.ANNUAL_COMBINED_INCOME, DemographicInfoItem.NUMBER_OF_PEOPLE_LIVING_IN_HOUSEHOLD],
      ],
    );
  }
}

class PregnancyHistoryPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GifFormSection(
      sectionTitle: "Pregnancy History",
      enumType: PregnancyHistoryItem,
      itemRows: [
        [PregnancyHistoryItem.NUMBER_OF_PREGNANCIES, PregnancyHistoryItem.NUMBER_LIVE_BIRTHS],
        [PregnancyHistoryItem.NUMBER_STILLBORN, PregnancyHistoryItem.NUMBER_SPONTANEOUS_ABORTION],
        [PregnancyHistoryItem.NUMBER_INDUCED_ABORTION, PregnancyHistoryItem.NUMBER_NOW_LIVING],
        [PregnancyHistoryItem.WOMANS_AGE_AT_FIRST_PREGNANCY, PregnancyHistoryItem.DELIVERY_METHOD],
      ],
    );
  }
}

class GifFormSection extends StatelessWidget {
  final String sectionTitle;
  final List<List<GifItem>> itemRows;
  final Type enumType;

  const GifFormSection({super.key, required this.sectionTitle, required this.itemRows, required this.enumType});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GifRepo, ClientID>(builder: (context, repo, clientID, child) => FormSection(
      sectionTitle: sectionTitle,
      itemRows: itemRows,
      initialValues: repo.getAll(enumType, clientID.value).first,
      onSave: (m) async {
        await repo.updateAll(enumType, clientID.value, m);
      },
    ));
  }
}

class FormSection extends StatefulWidget {
  final String sectionTitle;
  final List<List<GifItem>> itemRows;
  final Future<Map<String, String>> initialValues;
  final Function(Map<String, String>) onSave;

  FormSection({required this.sectionTitle, required this.itemRows, required this.initialValues, required this.onSave});

  @override
  State<StatefulWidget> createState() => FormSectionState();
}

class FormSectionState extends State<FormSection> {
  bool editEnabled = false;
  Map<String, String> initialValues = {};
  Map<GifItem, TextEditingController> controllers = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(future: widget.initialValues, builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Container();
      }
      initialValues = snapshot.data!;
      return ExpandableInfoPanel(
        title: widget.sectionTitle,
        subtitle: "",
        trailing: _trailingWidget(),
        contents: _rows(),
      );
    });
  }

  List<Widget> _rows() {
    return widget.itemRows
        .map((row) => Row(children: row.map((item) => Flexible(child: _itemWidget(item))).toList()))
        .toList();
  }

  Widget _itemWidget(GifItem item) {
    var initialValue = initialValues[item.name] ?? "";
    var controller = controllers.putIfAbsent(item, () => TextEditingController(text: initialValue));
    Widget inputWidget = TextFormField(
      decoration: InputDecoration(
        labelText: item.label,
      ),
      enabled: editEnabled,
      controller: controller,
    );
    if (item.optionsEnum != null) {
      inputWidget = DropdownButtonFormField<String>(
        items: item.optionsEnum!.map((v) => DropdownMenuItem<String>(
          child: Text(v.name),
          value: v.name,
        )).toList(),
        onChanged: !editEnabled ? null : (value) => setState(() {
          controller.text = value ?? "";
        }),
        decoration: InputDecoration(
          labelText: item.label,
        ),
        value: initialValue.isEmpty ? null : initialValue,
      );
    }
    List<Widget> children = [Expanded(child: inputWidget)];
    if (editEnabled) {
      children.add(AddCommentButton());
    } else if (Random.secure().nextDouble() < 0.3) {
      children.add(ViewCommentsButton(numComments: 1));
    }
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Row(mainAxisSize: MainAxisSize.min, children: children,),
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

class CommentDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CommentDialogState();
}

class CommentDialogState extends State<CommentDialog> {
  List<String> comments = [];

  @override
  Widget build(BuildContext context) {
    var commentWidgets = comments.map((c) => TextFormField(initialValue: c,));
    var contents = Column(children: [...commentWidgets, TextButton(onPressed: () {}, child: Text("Add Comment"))],);
    return AlertDialog(
      title: Text("Comments"),
      content: contents,
      actions: [
        TextButton(onPressed: () {}, child: Text("Cancel")),
        TextButton(onPressed: () {}, child: Text("Save")),
      ],
    );
  }
}

class AddCommentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(message: "Add Comment", child: IconButton(icon: Icon(Icons.add_comment), onPressed: () {
      showDialog(context: context, builder: (context) => CommentDialog(),);
    },));
  }
}

class ViewCommentsButton extends StatelessWidget {
  final int numComments;

  const ViewCommentsButton({super.key, required this.numComments});

  @override
  Widget build(BuildContext context) {
    var icon = Stack(
      children: <Widget>[
        new Icon(Icons.comment),
        new Positioned(
          right: 0,
          child: new Container(
            padding: EdgeInsets.all(1),
            decoration: new BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: new Text(
              '$numComments',
              style: new TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
    return Tooltip(message: "View Comments", child: IconButton(onPressed: () {}, icon: icon));
  }
}
