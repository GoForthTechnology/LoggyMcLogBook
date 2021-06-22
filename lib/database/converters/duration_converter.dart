
import 'package:floor/floor.dart';

class  DurationConverter  extends  TypeConverter<Duration , int> {
  @override
  Duration  decode(int databaseValue) {
    return  Duration(milliseconds: databaseValue);
  }

  @override
  int encode(Duration value) {
    return value.inMilliseconds;
  }
}