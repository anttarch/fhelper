import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'exchange.g.dart';

enum EType { income, expense, transfer, installment }

@Collection()
class Exchange {
  Exchange({
    required this.accountId,
    required this.description,
    required this.date,
    required this.eType,
    required this.typeId,
    required this.value,
    this.id = Isar.autoIncrement,
    this.accountIdEnd,
    this.cardId,
    this.installments,
    this.installmentValue,
  }) : assert(
          eType == EType.transfer ? accountIdEnd != null : accountIdEnd == null,
          eType == EType.transfer
              ? 'Needs a destination account'
              : 'Cannot have a destination account',
        );

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

  @override
  String toString() {
    //ignore: lines_longer_than_80_chars
    return 'Exchange(id: $id, accountId: $accountId, accountIdEnd: $accountIdEnd, cardId: $cardId, date: $date, description: $description, eType: $eType, installments: $installments, installmentValue: $installmentValue, typeId: $typeId, value: $value)';
  }

  Exchange copyWith({
    Id? id,
    int? accountId,
    int? accountIdEnd,
    int? cardId,
    DateTime? date,
    String? description,
    EType? eType,
    int? installments,
    double? installmentValue,
    int? typeId,
    double? value,
  }) {
    return Exchange(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountIdEnd: accountIdEnd ?? this.accountIdEnd,
      cardId: cardId ?? this.cardId,
      date: date ?? this.date,
      description: description ?? this.description,
      eType: eType ?? this.eType,
      installments: installments ?? this.installments,
      installmentValue: installmentValue ?? this.installmentValue,
      typeId: typeId ?? this.typeId,
      value: value ?? this.value,
    );
  }
}

final _monthPeriod = (
  DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ),
  DateTime.now()
);

int getWeekday(BuildContext context) {
  final localizations = MaterialLocalizations.of(context);
  // 0 = sunday ... 6 = saturday
  final firstDayOfWeek = localizations.firstDayOfWeekIndex;

  // 1 = monday ... 7 = sunday
  final weekday = DateTime.now().weekday;

  // this switch convers the ISO8601 weekday format to local
  switch (firstDayOfWeek) {
    case 0:
      final iso8601toSunday = <int, int>{
        1: 2,
        2: 3,
        3: 4,
        4: 5,
        5: 6,
        6: 7,
        7: 1,
      };
      return iso8601toSunday.entries
          .where((e) => e.key == weekday)
          .single
          .value;
    case 6:
      final iso8601toSaturday = <int, int>{
        1: 3,
        2: 4,
        3: 5,
        4: 6,
        5: 7,
        6: 1,
        7: 2,
      };
      return iso8601toSaturday.entries
          .where((e) => e.key == weekday)
          .single
          .value;
    default:
      return weekday;
  }
}

Future<double> getSumValue(
  Isar isar,
  BuildContext context, {
  int time = 0,
}) async {
  final weekday = getWeekday(context);
  final now = DateTime.now();

  final today = await isar.exchanges
      .filter()
      .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
      .eTypeLessThan(EType.transfer)
      .installmentsIsNull()
      .valueProperty()
      .sum();

  final week = await isar.exchanges
      .filter()
      .dateBetween(
        _monthPeriod.$1.subtract(Duration(days: weekday - 1)),
        _monthPeriod.$2,
      )
      .eTypeLessThan(EType.transfer)
      .installmentsIsNull()
      .valueProperty()
      .sum();

  final month = await isar.exchanges
      .filter()
      .dateBetween(DateTime(now.year, now.month), now)
      .eTypeLessThan(EType.transfer)
      .installmentsIsNull()
      .valueProperty()
      .sum();

  final timeTable = <int, double>{
    0: today,
    1: week,
    2: month,
  };

  return timeTable[time]!;
}

/// `time` map
/// 0 -> today
/// 1 -> all
Future<double> getSumValueByAttribute(
  Isar isar,
  int propertyId,
  AttributeType? attributeType, {
  int time = 0,
}) async {
  var value = 0.0;

  if (propertyId == -1) {
    return value;
  }

  if (attributeType != null) {
    if (attributeType == AttributeType.account) {
      if (time == 0) {
        // Normal exchanges
        value = await isar.exchanges
            .where()
            .filter()
            .accountIdEqualTo(propertyId)
            .eTypeLessThan(EType.transfer)
            .installmentsIsNull()
            .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
            .valueProperty()
            .sum();
        // Transfers from account
        value -= await isar.exchanges
            .where()
            .filter()
            .accountIdEqualTo(propertyId)
            .eTypeEqualTo(EType.transfer)
            .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
            .valueProperty()
            .sum();
        // Transfers to account
        value += await isar.exchanges
            .where()
            .filter()
            .accountIdEndEqualTo(propertyId)
            .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
            .valueProperty()
            .sum();
      } else {
        // Normal exchanges
        value = await isar.exchanges
            .where()
            .filter()
            .accountIdEqualTo(propertyId)
            .eTypeLessThan(EType.transfer)
            .installmentsIsNull()
            .valueProperty()
            .sum();
        // Transfers from account
        value -= await isar.exchanges
            .where()
            .filter()
            .accountIdEqualTo(propertyId)
            .eTypeEqualTo(EType.transfer)
            .valueProperty()
            .sum();
        // Transfers to account
        value += await isar.exchanges
            .where()
            .filter()
            .accountIdEndEqualTo(propertyId)
            .valueProperty()
            .sum();
      }
      // CardBills associated
      value += await getCardBillSumByAccount(isar, propertyId, time: time);
    }
  } else {
    value = await isar.exchanges
        .where()
        .filter()
        .cardIdEqualTo(propertyId)
        .not()
        .eTypeEqualTo(EType.installment)
        .valueProperty()
        .sum();
  }
  return value;
}

/// `dependency` map
/// 0 -> [Exchange]
/// 1 -> [CardBill] (Not available for types)
Future<int> checkForAttributeDependencies(
  Isar isar,
  int propertyId,
  AttributeType? attributeType, {
  int dependency = -1,
}) async {
  var dependenciesCount = 0;

  if (propertyId == -1) {
    return dependenciesCount;
  }

  if (attributeType != null) {
    switch (attributeType) {
      case AttributeType.account:
        final exchanges = await isar.exchanges
            .filter()
            .accountIdEqualTo(propertyId)
            .or()
            .accountIdEndEqualTo(propertyId)
            .count();
        final cardBills =
            await isar.cardBills.filter().accountIdEqualTo(propertyId).count();
        if (dependency > -1) {
          if (dependency == 1) {
            return cardBills;
          }
          return exchanges;
        }
        dependenciesCount = exchanges + cardBills;
      case AttributeType.incomeType:
      case AttributeType.expenseType:
        final exchanges =
            await isar.exchanges.filter().typeIdEqualTo(propertyId).count();
        if (dependency == 0) {
          return exchanges;
        }
        dependenciesCount = exchanges;
    }
  } else {
    dependenciesCount =
        await isar.exchanges.filter().cardIdEqualTo(propertyId).count();
  }
  return dependenciesCount;
}

/// `time` map
/// 0 -> today
/// 1 -> all
Future<int> getAttributeUsage(
  Isar isar,
  int attributeId,
  AttributeType attributeType,
  int time,
) async {
  var percentage = 0;

  if (time == 0) {
    final todayExchanges = await isar.exchanges
        .filter()
        .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
        .count();
    if (todayExchanges > 0 && attributeType == AttributeType.account) {
      final accountCount = await isar.exchanges
          .filter()
          .accountIdEqualTo(attributeId)
          .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
          .count();
      percentage = ((accountCount / todayExchanges) * 100).round();
    }
  } else {
    final totalExchanges = await isar.exchanges.count();
    if (totalExchanges > 0) {
      switch (attributeType) {
        case AttributeType.account:
          {
            final accountCount = await isar.exchanges
                .filter()
                .accountIdEqualTo(attributeId)
                .count();
            return ((accountCount / totalExchanges) * 100).round();
          }
        case AttributeType.expenseType:
        case AttributeType.incomeType:
          {
            final typeCount = await isar.exchanges
                .filter()
                .typeIdEqualTo(attributeId)
                .count();
            percentage = ((typeCount / totalExchanges) * 100).round();
          }
      }
    }
  }

  return percentage;
}

Future<List<Exchange>> getExchanges(
  Isar isar,
  BuildContext context, {
  int time = 0,
}) async {
  final weekday = getWeekday(context);
  final now = DateTime.now();

  final today = await isar.exchanges
      .where()
      .filter()
      .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
      .not()
      .eTypeEqualTo(EType.installment)
      .sortByDateDesc()
      .findAll();

  final week = await isar.exchanges
      .where()
      .filter()
      .dateBetween(
        _monthPeriod.$1.subtract(Duration(days: weekday - 1)),
        _monthPeriod.$2,
      )
      .not()
      .eTypeEqualTo(EType.installment)
      .sortByDateDesc()
      .findAll();

  final month = await isar.exchanges
      .where()
      .filter()
      .dateBetween(DateTime(now.year, now.month), now)
      .not()
      .eTypeEqualTo(EType.installment)
      .sortByDateDesc()
      .findAll();

  final timeTable = <int, List<Exchange>>{
    0: today,
    1: week,
    2: month,
  };

  return timeTable[time]!;
}

Future<double> getAvailableLimit(Isar isar, fhelper.Card card) async {
  final usedLimit = (await getSumValueByAttribute(isar, card.id, null)) * (-1);
  return card.limit - usedLimit;
}
