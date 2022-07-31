
import 'package:lmlb/database/daos/appointment_dao.dart';
import 'package:lmlb/database/daos/client_dao.dart';
import 'package:lmlb/database/daos/fakes/fake_appointment_dao.dart';
import 'package:lmlb/database/daos/fakes/fake_client_dao.dart';
import 'package:lmlb/database/daos/fakes/fake_invoice_dao.dart';
import 'package:lmlb/database/daos/invoice_dao.dart';
import 'package:lmlb/database/database.dart';

class FakeDatabase extends AppDatabase {

  final AppointmentDao _appointmentDao;
  final ClientDao _clientDao;
  final InvoiceDao _invoiceDao;

  FakeDatabase() :
        _appointmentDao = FakeAppointmentDao(),
        _clientDao = FakeClientDao(),
        _invoiceDao = FakeInvoiceDao();

  @override
  AppointmentDao get appointmentDao => _appointmentDao;

  @override
  ClientDao get clientDao => _clientDao;

  @override
  InvoiceDao get invoiceDao => _invoiceDao;
}
