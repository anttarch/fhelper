import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'exchange.g.dart';

enum EType { income, expense }

@Collection()
class Exchange {
  Exchange({
    this.id = Isar.autoIncrement,
    required this.accountId,
    this.cardId,
    required this.description,
    required this.date,
    this.installments,
    this.installmentValue,
    required this.eType,
    required this.typeId,
    required this.value,
  });

  final Id id; // Isar id
  final int accountId; // Account (attribute) linked
  final int? cardId; // Card linked
  final DateTime date;
  final String description; // Name
  final int? installments; // Installments amount
  final double? installmentValue; // Value of each installment

  @enumerated
  final EType eType; // Exchange type
  final int typeId; // Type (attribute) linked
  final double value; // Monetary value
}

int _getWeekday(BuildContext context) {
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  final int firstDayOfWeek = localizations.firstDayOfWeekIndex;

  // 0 = sunday ... 6 = saturday
  final int weekday = DateTime.now().weekday;

  // this switch convers the ISO8601 weekday format to local
  switch (firstDayOfWeek) {
    case 0:
      {
        final Map<int, int> iso8601toSunday = {
          1: 2,
          2: 3,
          3: 4,
          4: 5,
          5: 6,
          6: 7,
          7: 1,
        };
        return iso8601toSunday.entries.where((e) => e.key == weekday).single.value;
      }
    case 6:
      {
        final Map<int, int> iso8601toSaturday = {
          1: 3,
          2: 4,
          3: 5,
          4: 6,
          5: 7,
          6: 1,
          7: 2,
        };
        return iso8601toSaturday.entries.where((e) => e.key == weekday).single.value;
      }
    default:
      return weekday;
  }
}

Future<double> getSumValue(
  Isar isar,
  BuildContext context, {
  int time = 0,
}) async {
  final int weekday = _getWeekday(context);

  final double today = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
        DateTime.now(),
      )
      .valueProperty()
      .sum();

  final double week = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        DateTime.now().subtract(Duration(days: weekday)),
        DateTime.now(),
      )
      .valueProperty()
      .sum();

  final double month = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        DateTime(DateTime.now().year, DateTime.now().month),
        DateTime.now(),
      )
      .valueProperty()
      .sum();

  final Map<int, double> timeTable = {
    0: today,
    1: week,
    2: month,
  };

  return timeTable[time]!;
}

Future<List<Exchange>> getExchanges(
  Isar isar,
  BuildContext context, {
  int time = 0,
}) async {
  final int weekday = _getWeekday(context);

  final List<Exchange> today = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
        DateTime.now(),
      )
      .sortByDateDesc()
      .findAll();

  final List<Exchange> week = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        DateTime.now().subtract(Duration(days: weekday)),
        DateTime.now(),
      )
      .sortByDateDesc()
      .findAll();

  final List<Exchange> month = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        DateTime(DateTime.now().year, DateTime.now().month),
        DateTime.now(),
      )
      .sortByDateDesc()
      .findAll();

  final Map<int, List<Exchange>> timeTable = {
    0: today,
    1: week,
    2: month,
  };

  return timeTable[time]!;
}
