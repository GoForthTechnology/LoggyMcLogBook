
import 'package:floor/floor.dart';
import 'package:lmlb/entities/invoice.dart';

class CurrencyConverter extends TypeConverter<Currency, int> {
  @override
  decode(int databaseValue) {
    return Currency.values[databaseValue];
  }

  @override
  int encode(value) {
    return value.index;
  }
}