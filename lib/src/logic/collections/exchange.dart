import 'package:isar/isar.dart';

part 'exchange.g.dart';

enum EType { income, expense }

@Collection()
class Exchange {
  Exchange({
    this.id = Isar.autoIncrement,
    required this.account,
    this.cardId,
    required this.description,
    required this.date,
    this.installments,
    this.installmentValue,
    required this.eType,
    required this.type,
    required this.value,
  });

  final Id id; // Isar id
  final String account; // Account linked
  final int? cardId; // Card linked
  final DateTime date;
  final String description; // Name
  final int? installments; // Installments amount
  final double? installmentValue; // Value of each installment

  @enumerated
  final EType eType; // Exchange type
  final String type; // Type (category)
  final double value; // Monetary value
}

Future<double> getSumValue(Isar isar, {int time = 0}) async {
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
        DateTime.now().subtract(Duration(days: DateTime.now().weekday)),
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

Future<List<Exchange>> getExchanges(Isar isar, {int time = 0}) async {
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
        DateTime.now().subtract(Duration(days: DateTime.now().weekday)),
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
