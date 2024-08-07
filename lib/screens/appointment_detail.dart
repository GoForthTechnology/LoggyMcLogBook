import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/reminder.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/materials.dart';
import 'package:lmlb/repos/reminders.dart';
import 'package:lmlb/widgets/appointment_info_panel.dart';
import 'package:lmlb/widgets/fup_form.dart';
import 'package:lmlb/widgets/gif_form.dart';
import 'package:lmlb/widgets/info_panel.dart';
import 'package:lmlb/widgets/navigation_rail.dart';
import 'package:lmlb/widgets/new_appointment_dialog.dart';
import 'package:lmlb/widgets/new_material_client_order_dialog.dart';
import 'package:lmlb/widgets/new_reminder_dialog.dart';
import 'package:lmlb/widgets/overview_tile.dart';
import 'package:lmlb/widgets/reproductive_history_panel.dart';
import 'package:provider/provider.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentID;
  final String clientID;

  const AppointmentDetailScreen(
      {super.key,
      @PathParam() required this.appointmentID,
      @PathParam() required this.clientID});

  @override
  Widget build(BuildContext context) {
    return appointmentWidget(
        appointmentID,
        clientID,
        (appointment) => clientWidget(
            appointment!.clientID,
            (client) => NavigationRailScreen(
                  item: NavigationItem.appointments,
                  title: Text(
                      "${appointment.type.prettyName()} for ${client!.fullName()}"),
                  content: ListView(
                    children: [
                      ReproductiveHistoryPanel(
                        client: client,
                        titleOverride: "Client Overview",
                      ),
                      AppointmentInfoPanel(
                        appointment: appointment,
                      ),
                      PreviousAppointmentPanel(
                        currentAppointment: appointment,
                      ),
                      if (appointment.type.followUpNum() != null)
                        FollowUpForm(
                          clientID: clientID,
                          followUpNum: appointment.type.followUpNum()!,
                        ),
                      NextStepsPanel(
                        client: client,
                        appointment: appointment,
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                              child: Text("Additional Info",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium))),
                      GifForm(
                        clientID: appointment.clientID,
                      ),
                    ],
                  ),
                )));
  }
}

class PreviousAppointmentPanel extends StatelessWidget {
  final Appointment currentAppointment;

  const PreviousAppointmentPanel({super.key, required this.currentAppointment});

  @override
  Widget build(BuildContext context) {
    return Consumer<Appointments>(
      builder: (context, repo, child) => FutureBuilder<Appointment?>(
          future: repo.getPrevious(currentAppointment),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return emptyPanel();
            }
            return panelForAppointment(snapshot.data!);
          }),
    );
  }

  Widget emptyPanel() {
    return ExpandableInfoPanel(
        title: "Previous Appointment", subtitle: "None", contents: []);
  }

  Widget panelForAppointment(Appointment appointment) {
    return ExpandableInfoPanel(
        title: "Previous Appointment",
        subtitle: appointment.toString(),
        contents: [
          OverviewTile(
            attentionLevel: OverviewAttentionLevel.grey,
            title: "Notes",
            subtitle:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            icon: Icons.note,
            actions: [
              OverviewAction(title: "Edit"),
            ],
          ),
        ]);
  }
}

class NextStepsPanel extends StatelessWidget {
  final Client client;
  final Appointment appointment;

  const NextStepsPanel(
      {super.key, required this.appointment, required this.client});

  @override
  Widget build(BuildContext context) {
    AppointmentType nextType =
        AppointmentType.values[appointment.type.index + 1];
    return ExpandableInfoPanel(title: "Next Steps", subtitle: "", contents: [
      Consumer<Appointments>(
        builder: (context, repo, child) => StreamBuilder<Appointment?>(
          stream: repo.getNext(appointment).asStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return OverviewTile(
                attentionLevel: OverviewAttentionLevel.grey,
                title: "Schedule ${nextType.prettyName()}",
                icon: Icons.event,
                actions: [
                  OverviewAction(
                      title: "Scheduled for ${snapshot.data!.timeStr()}"),
                ],
              );
            }
            return Consumer<Reminders>(
              builder: (context, repo, child) => StreamBuilder<List<Reminder>>(
                stream: repo.forAppointment(appointment.id!),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    var reminder = snapshot.data!.first;
                    return OverviewTile(
                      attentionLevel: OverviewAttentionLevel.grey,
                      title: "Schedule ${nextType.prettyName()}",
                      icon: Icons.event,
                      actions: [
                        OverviewAction(
                            title:
                                "Reminder set for ${reminder.triggerTime.toString()}"),
                      ],
                    );
                  }
                  var title = "Schedule ${nextType.prettyName()}";
                  return OverviewTile(
                    attentionLevel: OverviewAttentionLevel.green,
                    title: title,
                    icon: Icons.event,
                    actions: [
                      OverviewAction(
                          title: "Set Reminder",
                          onPress: () => showDialog(
                                context: context,
                                builder: (context) => NewReminderDialog(
                                  reminderType:
                                      ReminderType.SCHEDULE_APPOINTMENT,
                                  defaultTriggerDaysAway: 30,
                                  defaultTitle:
                                      "$title for ${client.fullName()}",
                                  appointmentID: appointment.id,
                                  clientID: client.id,
                                ),
                              )),
                      OverviewAction(
                          title: "Schedule",
                          onPress: () => showDialog(
                                context: context,
                                builder: (context) => NewAppointmentDialog(
                                    clientID: appointment.clientID),
                              )),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
      Consumer<MaterialsRepo>(
          builder: (context, repo, child) => OverviewTile(
                attentionLevel: OverviewAttentionLevel.grey,
                title: "Order Materials",
                icon: Icons.palette,
                actions: [
                  OverviewAction(
                      title: "Order",
                      onPress: () => showDialog(
                          context: context,
                          builder: (context) => NewClientOrderDialog(
                                repo: repo,
                                clientID: client.id!,
                                editingEnabled: true,
                              ))),
                ],
              )),
    ]);
  }
}

class FollowUpForm extends StatelessWidget {
  final String clientID;
  final int followUpNum;

  const FollowUpForm(
      {super.key, required this.clientID, required this.followUpNum});

  @override
  Widget build(BuildContext context) {
    return ExpandableInfoPanel(
      title: "Follow Up Form",
      subtitle: "",
      contents: [
        FollowUpFormStepper(
          clientID: clientID,
          followUpNum: followUpNum,
        )
      ],
    );
  }
}

Widget appointmentWidget(String appointmentID, String clientID,
    Widget Function(Appointment?) build) {
  return Consumer<Appointments>(
      builder: (context, repo, child) => StreamBuilder<Appointment?>(
            stream:
                repo.stream(appointmentID: appointmentID, clientID: clientID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return build(snapshot.data);
            },
          ));
}

Widget clientWidget(String clientID, Widget Function(Client?) build) {
  return Consumer<Clients>(
      builder: (context, repo, child) => StreamBuilder<Client?>(
            stream: repo.stream(clientID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return build(snapshot.data);
            },
          ));
}

// TODO: delete this dead code
/*class AppointmentDetailModel extends ClientSelectorModel {
  final Appointments appointmentRepo;
  final formKey = GlobalKey<FormState>();
  Appointment? appointment;

  String? clientId;
  DateTime? appointmentDate;
  TimeOfDay? appointmentTime;
  AppointmentType? appointmentType;
  TextEditingController priceController = new TextEditingController();

  AppointmentDetailModel({
    this.appointment,
    required this.appointmentRepo,
  }) : super(appointment?.clientId) {
    clientId = appointment?.clientId;
    appointmentType = appointment?.type;
    priceController.text = appointment?.price.toString() ?? "";
    final time = appointment?.time;
    if (time != null) {
      appointmentDate = DateUtils.dateOnly(time);
      appointmentTime = TimeOfDay.fromDateTime(time);
    }
    notifyListeners();
  }

  Future<void> addToInvoice(Invoice invoice) {
    return appointmentRepo.addToInvoice(appointment!, invoice).then((a) {
      appointment = a;
      notifyListeners();
    });
  }

  void updateClientId(String? value) {
    clientId = value;
    notifyListeners();
  }

  void updateAppointmentType(AppointmentType? value) {
    appointmentType = value;
    notifyListeners();
  }

  void updateAppointmentDate(DateTime? value) {
    appointmentDate = value;
    notifyListeners();
  }

  void updateAppointmentTime(TimeOfDay? value) {
    appointmentTime = value;
    notifyListeners();
  }

  Future<void> save() {
    final appointmentTime = DateTime(
        appointmentDate!.year,
        appointmentDate!.month,
        appointmentDate!.day,
        appointmentDate!.hour,
        appointmentDate!.minute);
    if (appointment == null) {
      return appointmentRepo.add(
          clientId!, appointmentTime, Duration(hours: 1), appointmentType!, int.parse(priceController.text));
    } else {
      var updatedAppointment = Appointment(
          appointment!.id, appointmentType!, appointmentTime, appointment!.duration, appointment!.clientId, int.parse(priceController.text), appointment!.invoiceId);
      return appointmentRepo.updateAppointment(updatedAppointment);
    }
  }
}

class AppointmentDetailScreen extends StatelessWidget {
  final String? appointmentId;
  final String? clientId;
  final AppointmentType? appointmentType;

  const AppointmentDetailScreen({
    Key? key,
    @PathParam() this.appointmentId,
    this.clientId,
    this.appointmentType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Appointments, Clients>(builder: (context, appointmentRepo, clientRepo, child) => StreamBuilder<Appointment?>(
      stream: appointmentId == null ? Stream.value(null) : appointmentRepo.stream(appointmentId!),
      builder: (context, snapshot) {
        var appointment = snapshot.data;
        if (appointmentId != null && appointment == null) {
          return Container();
        }
        return ChangeNotifierProvider(
          create: (context) {
            var model = AppointmentDetailModel(
              appointment: appointment,
              appointmentRepo: appointmentRepo,
            );
            if (appointment == null) {
              model.updateClientId(clientId);
              model.updateAppointmentType(appointmentType);
            }
            return model;
          },
          child: Consumer<AppointmentDetailModel>(builder: (context, model, child) => body(context, model)),
        );
      },
    ));
  }

  Widget body(BuildContext context, AppointmentDetailModel model) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(appointmentId == null ? 'New Appointment' : 'Appointment Info'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () => _onSave(context, model),
          )
        ],
      ),
      body: Form(
        key: model.formKey,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClientSelector(context, model),
              _buildTypeSelector(context, model),
              _buildEventDate(context, model),
              _buildEventTime(context, model),
              _buildPrice(context, model),
              _buildInvoiceId(model),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave(BuildContext context, AppointmentDetailModel model) {
    if (model.formKey.currentState!.validate()) {
      model.save().then((_) => Navigator.of(context).pop());
    } else {
      print("Validation error");
    }
  }

  Widget _buildInvoiceId(AppointmentDetailModel model) {
    return Consumer<Invoices>(builder: (context, invoiceRepo, child) {
      var invoiceF = invoiceRepo.getSingle(model.appointment?.invoiceId);
      var pendingF = invoiceRepo.getPending(clientId: model.clientId);
      return FutureBuilder(
        future: Future.wait([invoiceF, pendingF]),
        builder: (context, snapshot) {
          Invoice? invoice;
          List<Invoice> pendingInvoices = [];
          if (snapshot.data != null) {
            final dataF = snapshot.data! as List<Object?>;
            invoice = dataF[0] as Invoice?;
            pendingInvoices = dataF[1] as List<Invoice>;
          }
          var invoiceNum = invoice?.invoiceNumStr();
          Widget content;
          if (invoiceNum != null) {
            void viewInvoice() {
              AutoRouter.of(context).push(InvoiceDetailScreenRoute(clientId: model.clientId, invoiceId: invoice?.id));
            }
            content = Row(children: [
              Text("#$invoiceNum (${invoice!.status().name})"),
              TextButton(onPressed: viewInvoice, child: Text("View")),
            ]);
          } else {
            if (pendingInvoices.isEmpty) {
              void createInvoice() {
                AutoRouter.of(context).push(InvoiceDetailScreenRoute(clientId: model.clientId));
              }
              content = ElevatedButton(onPressed: createInvoice, child: Text("Create Invoice"));
            } else {
              var pendingInvoice = pendingInvoices.first;
              void editInvoice() {
                model.addToInvoice(pendingInvoice).then((_) {
                  AutoRouter.of(context).push(InvoiceDetailScreenRoute(clientId: model.clientId, invoiceId: pendingInvoice.id));
                });
              }
              content = ElevatedButton(onPressed: editInvoice, child: Text("Add to Invoice #${pendingInvoice.invoiceNumStr()}"));
            }
          }
          return InputContainer(title: "Invoice:", content: content);
        },
      );
    });
  }

  Widget _buildEventDate(BuildContext context, AppointmentDetailModel model) {
    final Widget display = model.appointmentDate == null
        ? Text("Select a date")
        : Text(model.appointmentDate!.toIso8601String());
    return InputContainer(
        title: "Appointment Date:",
        content: FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: model.appointmentDate,
            validator: (value) {
              if (value == null) {
                print("Invalid date!");
                return "Date required";
              }
              return null;
            },
            builder: (state) => GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: model.appointmentDate ?? DateTime.now(), // Refer step 1
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null) {
                    state.didChange(picked);
                    model.updateAppointmentDate(picked);
                  }
                },
                child: _showErrorOrDisplay(state, display))));
  }

  Widget _buildPrice(BuildContext context, AppointmentDetailModel model) {
    var formField = ConstrainedBox(constraints: BoxConstraints.tightFor(width: 100), child: TextFormField(
      controller: model.priceController,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          print("Invalid price!");
          return 'Please enter some text';
        }
        return null;
      },
    ));
    return Consumer<Clients>(builder: (context, clients, child) => FutureBuilder<Client?>(
      future: model.clientId == null ? Future.value(null) : clients.get(model.clientId!),
      builder: (context, snapshot) {
        var currency = "TBD";
        return InputContainer(title: "Appointment Price ($currency):", content: formField);
      },
    ));
  }

  Widget _buildEventTime(BuildContext context, AppointmentDetailModel model) {
    final Widget display = model.appointmentTime == null
        ? Text("Select a time")
        : Text(model.appointmentTime!.format(context));
    return InputContainer(
        title: "Appointment Time:",
        content: FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: model.appointmentTime,

            validator: (value) {
              if (value == null) {
                print("Invalid time!");
                return "Value required";
              }
              return null;
            },
            builder: (state) => GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  state.didChange(picked);
                  model.updateAppointmentTime(picked);
                }
              },
              child: _showErrorOrDisplay(state, display)),
        ));
  }

  Widget _buildTypeSelector(BuildContext context, AppointmentDetailModel model) {
    return InputContainer(
        title: "Appointment Type:",
        content: FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null) {
                print("Invalid type!");
                return "Select a value";
              }
              return null;
            },
            initialValue: model.appointmentType,
            builder: (state) => _showErrorOrDisplay(
                state,
                DropdownButton<AppointmentType>(
                  hint: Text('Please make a selection'),
                  items: AppointmentType.values.map((value) {
                    return DropdownMenuItem<AppointmentType>(
                      value: value,
                      child: new Text(value.name()),
                    );
                  }).toList(),
                  onChanged: (selection) {
                    state.didChange(selection);
                    model.updateAppointmentType(selection);
                  },
                  value: model.appointmentType,
                ))));
  }

  Widget _buildClientSelector(BuildContext context, AppointmentDetailModel model) {
    return ClientSelector(
      canEdit: model.appointment != null,
      includeInactive: false,
      selectedClientId: model.clientId,
      onUpdate: model.updateClientId,
    );
  }

  Widget _showErrorOrDisplay(FormFieldState state, Widget display) {
    return Column(
      children: [
        display,
        state.hasError
            ? Text(
                state.errorText!,
                style: TextStyle(color: Colors.red),
              )
            : Container()
      ],
    );
  }
}*/
