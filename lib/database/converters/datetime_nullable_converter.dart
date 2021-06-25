
import 'package:floor/floor.dart';
import 'package:lmlb/database/converters/datetime_converter.dart';

class  DateTimeNullableConverter  extends  TypeConverter <DateTime? , int> {
  final childConverter = DateTimeConverter();

  @override
  DateTime?  decode (int databaseValue) {
    return databaseValue < 0 ? null : childConverter.decode(databaseValue);
  }

  @override
  int encode(DateTime? value) {
    return value == null ? -1 : childConverter.encode(value);
  }
}