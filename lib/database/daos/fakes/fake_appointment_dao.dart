
import 'package:lmlb/database/daos/appointment_dao.dart';
import 'package:lmlb/entities/appointment.dart';

class FakeAppointmentDao extends AppointmentDao {
  @override
  Future<Appointment?> get(int id) {
    return Future.value(null);
  }

  @override
  Future<List<Appointment>> getAll() {
    return Future.value(List.empty());
  }

  @override
  Future<int> insert(Appointment appointment) {
    return Future.value(0);
  }

  @override
  Future<int> remove(Appointment appointment) {
    return Future.value(0);
  }

  @override
  Future<int> update(Appointment appointment) {
    return Future.value(0);
  }

}