
import 'package:floor/floor.dart' as floor;
import 'package:lmlb/entities/appointment.dart';

@floor.dao
abstract class AppointmentDao {

  @floor.Query('SELECT * FROM Appointment')
  Future<List<Appointment>> getAll();

  @floor.Query('SELECT * FROM Appointment WHERE id = :id')
  Future<Appointment?> get(int id);

  @floor.insert
  Future<int> insert(Appointment appointment);

  @floor.update
  Future<int> update(Appointment appointment);

  @floor.delete
  Future<int> remove(Appointment appointment);
}