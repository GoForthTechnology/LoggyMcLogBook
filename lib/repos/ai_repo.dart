import 'package:flutter/material.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/repos/reminders.dart';
import 'package:rxdart/rxdart.dart';

enum NextStepAction {
  addAppointmentToPendingInvoice,
  addAppointmentToNewInvoice,
  scheduleReminder,
  snoozeReminder,
  dismissReminder,
  assignClientNum,
}

enum ActionItemSeverity { urgent, warning, info, encourage }

enum ActionItemCategory { billing, onboarding, reminder }

class Identifiers {
  String clientID;
  String? appointmentID;
  String? invoiceID;
  String? reminderID;

  Identifiers(
      {required this.clientID,
      this.appointmentID,
      this.invoiceID,
      this.reminderID});
}

class ActionItem {
  final String title;
  final String subtitle;
  final ActionItemSeverity severity;
  final ActionItemCategory category;
  final List<NextStepAction> actions;
  final Identifiers identifiers;

  ActionItem(
      {required this.title,
      required this.subtitle,
      required this.severity,
      required this.category,
      required this.actions,
      required this.identifiers});
}

class ActionItemRepo extends ChangeNotifier {
  final Invoices invoiceRepo;
  final Appointments appointmentRepo;
  final Reminders reminderRepo;
  final Clients clientRepo;

  static const daysToUrgentUnbilledAppointment = 60;

  ActionItemRepo(this.invoiceRepo, this.appointmentRepo, this.reminderRepo,
      this.clientRepo);

  Stream<List<ActionItem>> getActionItems({required String clientID}) async* {
    yield* _newClientAIs(clientID).flatMap((ais) {
      if (ais.isNotEmpty) {
        return Stream.value(ais);
      }
      return Rx.combineLatest2<List<ActionItem>, List<ActionItem>,
              List<ActionItem>>(
          _reminderAIs(clientID),
          _appointmentAIs(clientID),
          (a, b) => [a, b].expand((e) => e).toList());
    });
  }

  Future<String> handleAction(ActionItem ai, NextStepAction a) async {
    switch (a) {
      case NextStepAction.assignClientNum:
        return doAssignClientNum(ai);
      case NextStepAction.addAppointmentToPendingInvoice:
        return doAddToInvoice(ai);
      case NextStepAction.addAppointmentToNewInvoice:
        return doCreateInvoice(ai);
      case NextStepAction.scheduleReminder:
        // TODO: Handle this case.
        break;
      case NextStepAction.snoozeReminder:
        // TODO: Handle this case.
        break;
      case NextStepAction.dismissReminder:
        // TODO: Handle this case.
        break;
    }
    return "TODO!";
  }

  Future<String> doAssignClientNum(ActionItem ai) async {
    var clientID = ai.identifiers.clientID;
    var client = await clientRepo.get(clientID);
    if (client == null) {
      return "Client could not be found!";
    }
    await clientRepo.assignClientNum(client);
    return "Client number assigned";
  }

  Future<String> doAddToInvoice(ActionItem ai) async {
    var clientID = ai.identifiers.clientID;
    var appointmentID = ai.identifiers.appointmentID;
    var invoiceID = ai.identifiers.invoiceID;
    if (appointmentID == null) {
      return "Appointment ID missing!";
    }
    if (invoiceID == null) {
      return "Invoice ID missing!";
    }
    var client = await clientRepo.get(clientID);
    if (client == null) {
      return "Client could not be found!";
    }
    var invoice =
        await invoiceRepo.get(clientID: clientID, invoiceID: invoiceID).first;
    if (invoice == null) {
      return "Invoice could not be found!";
    }
    var appointment = await appointmentRepo
        .stream(appointmentID: appointmentID, clientID: ai.identifiers.clientID)
        .first;
    if (appointment == null) {
      return "Appointment could not be found!";
    }
    await appointmentRepo
        .updateAppointment(appointment.copyWith(invoiceID: invoiceID));
    var appointmentEntries = invoice.appointmentEntries;
    appointmentEntries.add(AppointmentEntry(
      appointmentID: appointmentID,
      appointmentType: appointment.type,
      appointmentDate: appointment.time,
      price: client.defaultFollowUpPrice!,
    ));
    await invoiceRepo
        .update(invoice.copyWith(appointmentEntries: appointmentEntries));
    return "Appointment added to invoice #${invoice.invoiceNumStr()}";
  }

  Future<String> doCreateInvoice(ActionItem ai) async {
    var unbilledAppointments =
        await appointmentRepo.streamAll((a) => a.invoiceId == null).first;
    var client = await clientRepo.get(ai.identifiers.clientID);
    if (client == null) {
      return "Could not find client";
    }
    try {
      await invoiceRepo.create(ai.identifiers.clientID, client,
          appointments: unbilledAppointments);
      return "Invoice created";
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<ActionItem>> _newClientAIs(String clientID) async* {
    yield* clientRepo.stream(clientID).map((c) {
      if (c == null) {
        throw Exception("Client not found");
      }
      if (c.num != null) {
        return [];
      }
      return [
        ActionItem(
          title: "Assign Client Number",
          subtitle: "Assigning a client number will enable more functionality",
          category: ActionItemCategory.onboarding,
          severity: ActionItemSeverity.encourage,
          actions: [NextStepAction.assignClientNum],
          identifiers: Identifiers(clientID: clientID),
        ),
      ];
    });
  }

  Stream<List<ActionItem>> _reminderAIs(String clientID) async* {
    yield* reminderRepo.forClient(clientID).map((rs) => rs.map((r) {
          var hasTriggered = r.triggerTime.isBefore(DateTime.now());
          List<NextStepAction> actions = [];
          String subtitle;
          if (hasTriggered) {
            actions = [
              NextStepAction.scheduleReminder,
              NextStepAction.snoozeReminder,
              NextStepAction.dismissReminder,
            ];
            subtitle =
                "${r.triggerTime.difference(DateTime.now()).inDays} days overdue!";
          } else {
            actions = [
              NextStepAction.scheduleReminder,
              NextStepAction.snoozeReminder,
              NextStepAction.dismissReminder,
            ];
            subtitle = "Snoozed until ${r.triggerTime}";
          }
          return ActionItem(
            title: r.title,
            subtitle: subtitle,
            category: ActionItemCategory.reminder,
            severity: hasTriggered
                ? ActionItemSeverity.warning
                : ActionItemSeverity.info,
            actions: actions,
            identifiers: Identifiers(clientID: clientID, reminderID: r.id),
          );
        }).toList());
  }

  Stream<List<ActionItem>> _appointmentAIs(String clientID) async* {
    var pendingInvoice = await invoiceRepo.getPending(clientID: clientID).first;
    var unbilledAppointments = appointmentRepo
        .streamAll((a) => a.invoiceId == null, clientID: clientID);
    yield* unbilledAppointments.map((as) => as.map((a) {
          int daysSinceAppointment = DateTime.now().difference(a.time).inDays;
          var severity = daysSinceAppointment < 0
              ? ActionItemSeverity.info
              : daysSinceAppointment > daysToUrgentUnbilledAppointment
                  ? ActionItemSeverity.urgent
                  : ActionItemSeverity.warning;
          var action = pendingInvoice == null
              ? NextStepAction.addAppointmentToNewInvoice
              : NextStepAction.addAppointmentToPendingInvoice;
          return ActionItem(
            title: "Unbilled Appointment",
            subtitle: a.toString(),
            category: ActionItemCategory.billing,
            severity: severity,
            actions: [action],
            identifiers: Identifiers(
              clientID: clientID,
              appointmentID: a.id,
              invoiceID: pendingInvoice?.id,
            ),
          );
        }).toList());
  }
}
