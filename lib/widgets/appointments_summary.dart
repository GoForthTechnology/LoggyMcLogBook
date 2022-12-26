
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/entities/appointment.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/invoice.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:lmlb/routes.gr.dart';
import 'package:lmlb/screens/appointments.dart';
import 'package:lmlb/widgets/stream_widget.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class AppointmentSummaryModel extends WidgetModel<AppointmentSummaryState> {
  final Client client;

  AppointmentSummaryModel(this.client, Appointments appointments, Invoices invoices) {
    final appointmentsS = appointments.streamAll((appointment) => appointment.clientId == client.id);
    final pendingInvoiceS = invoices.stream(Invoices.wherePending).map((invoices) {
      if (invoices.length > 1) {
        throw Exception("Cannot have more than one pending invoice!");
      }
      if (invoices.isEmpty) {
        return null;
      }
      return invoices.first;
    });

    Rx.combineLatest2(appointmentsS, pendingInvoiceS, createState).listen((state) {
      updateState(state);
    });
  }

  AppointmentSummaryState createState(List<Appointment> appointments, Invoice? pendingInvoice) {
    appointments.sort((a, b) => a.time.compareTo(b.time));

    var pastAppointments = appointments.where((a) => a.time.isBefore(DateTime.now()));
    var futureAppointments = appointments.where((a) => a.time.isAfter(DateTime.now()));
    var lastAppointment = pastAppointments.isEmpty ? null : pastAppointments.last;
    var nextAppointment = futureAppointments.isEmpty ? null : futureAppointments.first;
    var nextAppointmentType = lastAppointment?.type.next() ?? AppointmentType.INTRO;
    var toBeInvoicedAppointments = pastAppointments.where((a) => a.invoiceId == null).toList();
    return AppointmentSummaryState(
      client: client,
      numAppointments: appointments.length,
      lastAppointmentId: lastAppointment?.id,
      lastAppointmentSummary: lastAppointment?.toString() ?? "None",
      nextAppointmentId: nextAppointment?.id,
      nextAppointmentSummary: nextAppointment?.toString() ?? "None",
      pendingInvoiceId: pendingInvoice?.id,
      nextAppointmentType: nextAppointmentType,
      toBeInvoicedAppointments: toBeInvoicedAppointments,
    );
  }

  @override
  AppointmentSummaryState initialState() {
    return AppointmentSummaryState();
  }
}

class AppointmentSummaryState {
  final Client? client;

  final int numAppointments;
  final String lastAppointmentSummary;
  final String? lastAppointmentId;
  final String nextAppointmentSummary;
  final String? nextAppointmentId;
  final AppointmentType? nextAppointmentType;
  final List<Appointment> toBeInvoicedAppointments;

  final String? pendingInvoiceId;

  AppointmentSummaryState({
    this.client,
    this.numAppointments = 0,
    this.lastAppointmentSummary = "None",
    this.lastAppointmentId,
    this.nextAppointmentSummary = "None",
    this.nextAppointmentId,
    this.pendingInvoiceId,
    this.nextAppointmentType,
    this.toBeInvoicedAppointments = const [],
  });

  bool hasAppointments() {
    return numAppointments > 0;
  }

  bool hasLastAppointment() {
    return lastAppointmentId != null;
  }

  bool hasNextAppointment() {
    return nextAppointmentId != null;
  }

  bool hasPendingInvoice() {
    return pendingInvoiceId != null;
  }
}

class AppointmentsSummaryWidget extends StreamWidget<AppointmentSummaryModel, AppointmentSummaryState> {

  static Widget create(Client client) {
    return Consumer2<Appointments, Invoices>(builder: (context, appointments, invoices, child) {
      return ChangeNotifierProvider(
        create: (_) => AppointmentSummaryModel(client, appointments, invoices),
        builder: ((context, child) => AppointmentsSummaryWidget()),
      );
    });
  }

  Widget render(BuildContext context, AppointmentSummaryState state, AppointmentSummaryModel model) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text("Appointment Summary",
                style: Theme.of(context).textTheme.titleMedium))),
        _buildNextAppointment(state, context),
        _buildLastAppointment(state, context),
        _buildToBeInvoiced(state, context),
        _buildNumAppointments(state, context),
      ],
    );
  }

  Widget _paddedItem(Widget child) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0), child: child);
  }


  Widget _buildLastAppointment(AppointmentSummaryState state, BuildContext context) {
    return Row(
      children: [
        _paddedItem(Text("Last Appointment: ${state.lastAppointmentSummary}")),
        !state.hasLastAppointment() ? Container() : TextButton(
          child: Text("View"),
          onPressed: () {
            AutoRouter.of(context).push(AppointmentDetailScreenRoute(appointmentId: state.lastAppointmentId));
          },
        ),
      ],
    );
  }

  Widget _buildNextAppointment(AppointmentSummaryState state, BuildContext context) {
    Widget action = Container();
    if (state.hasNextAppointment()) {
      action = TextButton(
        child: Text("View"),
        onPressed: () {
          AutoRouter.of(context).push(AppointmentDetailScreenRoute(appointmentId: state.nextAppointmentId));
        },
      );
    } else if (state.nextAppointmentType != null) {
      action = TextButton(
        child: Text("Schedule ${state.nextAppointmentType!.name()}"),
        onPressed: () {
          AutoRouter.of(context).push(AppointmentDetailScreenRoute(
            clientId: state.client?.id,
            appointmentType: state.nextAppointmentType,
          ));
        },
      );
    }
    return Row(children: [
      _paddedItem(Text("Next Appointment: ${state.nextAppointmentSummary}")),
      action
    ]);
  }

  Widget _buildToBeInvoiced(AppointmentSummaryState state,BuildContext context) {
    return Row(children: [
      _paddedItem(Text("To Be Invoiced: ${state.toBeInvoicedAppointments.length}")),
      TextButton(onPressed: () => AutoRouter.of(context).push(AppointmentsScreenRoute(view: View.PENDING.name)), child: Text("View")),
    ]);
  }

  Widget _buildNumAppointments(AppointmentSummaryState state, BuildContext context) {
    return Row(
      children: [
        _paddedItem(Text(
            "# of Appointments: ${state.hasAppointments() ? state.numAppointments : "None"}")),
        !state.hasAppointments() ? Container() : TextButton(
          child: Text("View"),
          onPressed: () {
            AutoRouter.of(context).push(AppointmentsScreenRoute(view: View.ALL.name, client: state.client));
          },
        ),
      ],
    );
  }
}