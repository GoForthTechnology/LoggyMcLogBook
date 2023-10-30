
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
    if (item.optionsEnum != null) {
      return DropdownButtonFormField<String>(
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
    return TextFormField(
      decoration: InputDecoration(
        labelText: item.label,
      ),
      enabled: editEnabled,
      controller: controller,
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
