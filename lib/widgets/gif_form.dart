
import 'package:flutter/material.dart';
import 'package:lmlb/entities/client_demographic_info.dart';
import 'package:lmlb/widgets/info_panel.dart';

class GifForm extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
      title: "General Intake Form",
      subtitle: "Not yet completed",
      contents: [
        GeneralInfoPanel(),
        DemographicInfoPanel(),
        ExpandableInfoPanel(
          title: "Pregnancy History",
          subtitle: "",
          contents: [],
        ),
        ExpandableInfoPanel(
          title: "Medical History",
          subtitle: "",
          contents: [],
        ),
      ],
    );
  }
}

class GeneralInfoPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GeneralInfoPanelState();
}

class GeneralInfoPanelState extends State<GeneralInfoPanel> {
  bool enabled = false;

  Widget trailingWidget() {
    if (enabled) {
      return IconButton(onPressed: () => setState(() {
        enabled = false;
      }), icon: Icon(Icons.save),);
    }
    return IconButton(onPressed: () => setState(() {
      enabled = true;
    }), icon: Icon(Icons.edit),);
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
      title: "General Information",
      subtitle: "",
      trailing: trailingWidget(),
      contents: [
        Row(children: [
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "Woman's Name"
            ),
            enabled: this.enabled,
          )),
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "Man's Name"
            ),
            enabled: this.enabled,
          ))
        ],),
        Row(children: [
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "Woman's Date of Birth"
            ),
            enabled: this.enabled,
          )),
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "Man's Date of Birth"
            ),
            enabled: this.enabled,
          ))
        ],),
        TextFormField(
          decoration: InputDecoration(
              labelText: "Address"
          ),
          enabled: this.enabled,
        ),
        Row(children: [
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "City"
            ),
            enabled: this.enabled,
          )),
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "State"
            ),
            enabled: this.enabled,
          )),
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "ZIP"
            ),
            enabled: this.enabled,
          )),
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "Country"
            ),
            enabled: this.enabled,
          ))
        ],),
        Row(children: [
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "Email Address"
            ),
            enabled: this.enabled,
          )),
          Flexible(child: TextFormField(
            decoration: InputDecoration(
                labelText: "Phone Number"
            ),
            enabled: this.enabled,
          )),
        ],)
      ],
    );
  }
}

class DemographicInfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
      title: "Demographic Information",
      subtitle: "",
      contents: [
        Row(children: [
          Flexible(child: TextFormField(
            initialValue: "32",
            decoration: InputDecoration(
              labelText: "Woman's Age"
            ),
            enabled: false,
          )),
          Flexible(child: TextFormField(
            initialValue: "32",
            decoration: InputDecoration(
                labelText: "Man's Age"
            ),
            enabled: false,
          )),
        ],),
        Row(children: [
          Flexible(child: DropdownButtonFormField<int>(
            items: Ethnicity.values.map((ethnicity) => DropdownMenuItem<int>(
              child: Text(ethnicity.name),
              value: ethnicity.code,
            )).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
              labelText: "Woman's Ethnic Background",
            ),
          )),
        Flexible(child: DropdownButtonFormField<int>(
            items: Ethnicity.values.map((ethnicity) => DropdownMenuItem<int>(
              child: Text(ethnicity.name),
              value: ethnicity.code,
            )).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
                labelText: "Man's Ethnic Background"
            ),
          )),
        ],),
        Row(children: [
          Flexible(child: DropdownButtonFormField<int>(
            items: Religion.values.map((e) => DropdownMenuItem<int>(
              child: Text(e.name),
              value: e.code,
            )).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
              labelText: "Woman's Religion",
            ),
          )),
          Flexible(child: DropdownButtonFormField<int>(
            items: Religion.values.map((e) => DropdownMenuItem<int>(
              child: Text(e.name),
              value: e.code,
            )).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
                labelText: "Man's Religion"
            ),
          )),
        ],),
        Row(children: [
          Flexible(child: DropdownButtonFormField<int>(
            items: MaritalStatus.values.map((e) => DropdownMenuItem<int>(
              child: Text(e.name),
              value: e.code,
            )).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
              labelText: "Woman's Marital Status",
            ),
          )),
          Flexible(child: DropdownButtonFormField<int>(
            items: MaritalStatus.values.map((e) => DropdownMenuItem<int>(
              child: Text(e.name),
              value: e.code,
            )).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
                labelText: "Man's Marital Status"
            ),
          )),
        ],),
      ],
    );
  }
}