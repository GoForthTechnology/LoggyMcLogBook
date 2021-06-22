
import 'package:floor/floor.dart';
import 'package:lmlb/entities/appointment.dart';

class AppointmentTypeConverter extends TypeConverter<AppointmentType, int> {
  @override
  decode(int databaseValue) {
    return AppointmentType.values[databaseValue];
  }

  @override
  int encode(value) {
    return value.index;
  }
}