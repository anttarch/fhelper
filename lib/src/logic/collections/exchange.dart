import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'exchange.g.dart';

enum EType { income, expense, transfer }

@Collection()
class Exchange {
  Exchange({
    this.id = Isar.autoIncrement,
    required this.accountId,
    this.accountIdEnd,
    this.cardId,
    required this.description,
    required this.date,
    required this.eType,
    this.installments,
    this.installmentValue,
    required this.typeId,
    required this.value,
  }) : assert(eType == EType.transfer ? accountIdEnd != null : accountIdEnd == null);

  final Id id; // Isar id
  final int accountId; // Account (attribute) linked
  final int? accountIdEnd; // Destination account linked (Transfer only)
  final int? cardId; // Card linked
  final DateTime date;
  final String description; // Name
  @enumerated
  final EType eType; // Exchange type
  final int? installments; // Installments amount
  final double? installmentValue; // Value of each installment
  final int typeId; // Type (attribute) linked
  final double value; // Monetary value
}

int _getWeekday(BuildContext context) {
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  // 0 = sunday ... 6 = saturday
  final int firstDayOfWeek = localizations.firstDayOfWeekIndex;

  // 1 = monday ... 7 = sunday
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
      .and()
      .not()
      .eTypeEqualTo(EType.transfer)
      .valueProperty()
      .sum();

  final double week = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        DateTime.now().subtract(Duration(days: weekday)),
        DateTime.now(),
      )
      .not()
      .eTypeEqualTo(EType.transfer)
      .valueProperty()
      .sum();

  final double month = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        DateTime(DateTime.now().year, DateTime.now().month),
        DateTime.now(),
      )
      .not()
      .eTypeEqualTo(EType.transfer)
      .valueProperty()
      .sum();

  final Map<int, double> timeTable = {
    0: today,
    1: week,
    2: month,
  };

  return timeTable[time]!;
}

Future<double> getSumValueByAttribute(Isar isar, int propertyId, AttributeType? attributeType) async {
  double value = 0;

  if (propertyId == -1) {
    return value;
  } else {
    if (attributeType != null) {
      switch (attributeType) {
        case AttributeType.account:
          // Normal exchanges
          value = await isar.exchanges.where().filter().accountIdEqualTo(propertyId).and().not().eTypeEqualTo(EType.transfer).valueProperty().sum();
          // Transfers from account
          value -= await isar.exchanges.where().filter().accountIdEqualTo(propertyId).and().eTypeEqualTo(EType.transfer).valueProperty().sum();
          // Transfers to account
          value += await isar.exchanges.where().filter().accountIdEndEqualTo(propertyId).valueProperty().sum();

          return value;
        default:
          return value;
      }
    } else {
      value = await isar.exchanges.where().filter().cardIdEqualTo(propertyId).valueProperty().sum();
    }
    return value;
  }
}

Future<int> checkForAttributeDependencies(Isar isar, int propertyId, AttributeType? attributeType) async {
  int dependenciesCount = 0;

  if (propertyId == -1) {
    return dependenciesCount;
  } else {
    if (attributeType != null) {
      switch (attributeType) {
        case AttributeType.account:
          dependenciesCount = await isar.exchanges.filter().accountIdEqualTo(propertyId).or().accountIdEndEqualTo(propertyId).count();
          dependenciesCount += await isar.cards.filter().accountIdEqualTo(propertyId).count();
          return dependenciesCount;
        case AttributeType.incomeType:
        case AttributeType.expenseType:
          dependenciesCount = await isar.exchanges.filter().typeIdEqualTo(propertyId).count();
          return dependenciesCount;
        default:
          return dependenciesCount;
      }
    } else {
      dependenciesCount = await isar.exchanges.filter().cardIdEqualTo(propertyId).count();
    }
    return dependenciesCount;
  }
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

Future<double> getAvailableLimit(Isar isar, fhelper.Card card) async {
  final double usedLimit = (await getSumValueByAttribute(isar, card.id, null)) * (-1);
  return card.limit - usedLimit;
}
