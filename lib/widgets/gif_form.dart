
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class GeneralInfoPanel extends StatelessWidget {
  final bool enabled = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ExpandableInfoPanel(
      title: "General Information",
      subtitle: "",
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
          ))
        ],),
        /*Row(children: [
          TextFormField(
            decoration: InputDecoration(
                labelText: "Woman's Ethnic Background"
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: "Man's Ethnic Background"
            ),
          )
        ],),*/
      ],
    );
  }
}