import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

part 'card_bill.g.dart';

@Collection()
class CardBill {
  CardBill({
    required this.cardId,
    required this.date,
    required this.installmentIdList,
    this.id = Isar.autoIncrement,
    this.accountId = -1,
    this.confirmed = false,
    this.minimal,
  }) : assert(
          confirmed ? accountId != -1 : accountId == -1,
          confirmed ? 'Needs an account' : 'Cannot have an account',
        );

  final Id id; // CardBill id
  final int accountId; // Account linked
  final int cardId; // related card id
  final bool confirmed; // if bill is paid/confirmed
  final double? minimal; // minimal paid value
  final DateTime date; // CardBill date
  final List<int> installmentIdList; // CardBill installments

  @override
  String toString() =>
      //ignore: lines_longer_than_80_chars
      'CardBill(id: $id, accountId: $accountId, cardId: $cardId, confirmed: $confirmed, minimal: $minimal, date: $date, installmentIdList: $installmentIdList)';

  CardBill copyWith({
    Id? id,
    int? accountId,
    int? cardId,
    bool? confirmed,
    double? minimal,
    DateTime? date,
    List<int>? installmentIdList,
  }) {
    return CardBill(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      cardId: cardId ?? this.cardId,
      confirmed: confirmed ?? this.confirmed,
      minimal: minimal ?? this.minimal,
      date: date ?? this.date,
      installmentIdList: installmentIdList ?? this.installmentIdList,
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

/// Returns how many days there is in a month
int _daysOfMonth(int month) {
  final startMonth = DateTime(DateTime.now().year, month);
  final endMonth = DateTime(DateTime.now().year, month + 1);
  return endMonth.difference(startMonth).inDays;
}

/// Returns a [CardBill] from a given id
Future<CardBill?> getCardBillFromId(Isar isar, int id) async {
  final cardBill = await isar.cardBills.get(id);
  return cardBill;
}

/// Returns a [CardBill] from a given month period and a [fhelper.Card] id
Future<CardBill?> _getCardBill(Isar isar, DateTime date, int cardId) async {
  // allows for dates with days, ect.
  final startDate = DateTime(date.year, date.month);
  final lastDate = DateTime(date.year, date.month + 1);
  final cardBill = await isar.cardBills
      .filter()
      .cardIdEqualTo(cardId)
      .and()
      .dateGreaterThan(startDate)
      .and()
      .dateLessThan(lastDate)
      .findFirst();
  return cardBill;
}

/// Returns a non-confirmed [CardBill] from a specific time period
///
/// - 0 -> today
/// - 1 -> week
/// - 2 -> month
Future<Map<String, List<double>>> getPendingCardBills(
  Isar isar,
  BuildContext context, {
  int time = 0,
}) async {
  final weekday = getWeekday(context);
  final now = DateTime.now();

  final List<CardBill?> today = await isar.cardBills
      .filter()
      .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
      .confirmedEqualTo(false)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> week = await isar.cardBills
      .filter()
      .dateBetween(
        _monthPeriod.$1.subtract(Duration(days: weekday - 1)),
        _monthPeriod.$2,
      )
      .confirmedEqualTo(false)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> month = await isar.cardBills
      .filter()
      .dateBetween(
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1),
      )
      .confirmedEqualTo(false)
      .sortByDateDesc()
      .findAll();

  final timeTable = <int, List<CardBill?>>{
    0: today,
    1: week,
    2: month,
  };

  final nameValue = <String, List<double>>{};

  if (timeTable[time]!.isNotEmpty) {
    for (final bill in timeTable[time]!) {
      var value = 0.0;
      final card = await fhelper.getCardFromId(isar, bill!.cardId);
      for (final id in bill.installmentIdList) {
        final installment = await isar.exchanges.get(id);
        if (installment != null) {
          value += installment.value;
        }
      }
      nameValue.addAll({
        card!.name: [value, card.id.toDouble()]
      });
    }
  }

  return nameValue;
}

/// "Converts" [CardBill]s into [Exchange]s
///
/// **IMPORTANT NOTES:**
///
/// - The [Exchange.id] property has a fixed value of **-1**
/// - The [Exchange.typeId] property has the original [CardBill.id]
///
/// This has to be done to allow for differentiation and avoid conflict
/// between ids
Future<List<Exchange>> getCardBillsAsExchanges(
  Isar isar,
  BuildContext context, {
  int time = 0,
}) async {
  final weekday = getWeekday(context);
  final now = DateTime.now();

  final List<CardBill?> today = await isar.cardBills
      .filter()
      .dateBetween(_monthPeriod.$1, _monthPeriod.$2)
      .confirmedEqualTo(true)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> week = await isar.cardBills
      .filter()
      .dateBetween(
        _monthPeriod.$1.subtract(Duration(days: weekday - 1)),
        _monthPeriod.$2,
      )
      .confirmedEqualTo(true)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> month = await isar.cardBills
      .filter()
      .dateBetween(DateTime(now.year, now.month), now)
      .confirmedEqualTo(true)
      .sortByDateDesc()
      .findAll();

  final timeTable = <int, List<CardBill?>>{
    0: today,
    1: week,
    2: month,
  };

  final cardBill = timeTable[time]!;
  fhelper.Card? card;
  final cardBillExchange = <Exchange>[];

  if (cardBill.isNotEmpty) {
    for (final bill in cardBill) {
      var value = 0.0;
      for (final id in bill!.installmentIdList) {
        final installment = await isar.exchanges.get(id);
        if (installment != null) {
          value -= installment.value;
        }
      }
      card = await fhelper.getCardFromId(isar, bill.cardId);
      if (context.mounted) {
        cardBillExchange.add(
          Exchange(
            id: -1,
            accountId: bill.accountId,
            description: AppLocalizations.of(context)!.cardBill(card!.name),
            date: bill.date,
            eType: EType.expense,
            typeId: bill.id,
            value: value,
          ),
        );
      }
    }
  }

  return cardBillExchange;
}

/// `time` map
/// 0 -> today
/// 1 -> all
Future<double> getCardBillSumByAccount(
  Isar isar,
  int accountId, {
  int time = 0,
}) async {
  var value = 0.0;

  if (accountId == -1) {
    return value;
  } else {
    final cards = await isar.cards.where().findAll();
    for (final card in cards) {
      var cardBills = <CardBill>[];
      if (time == 0) {
        cardBills = await isar.cardBills
            .filter()
            .accountIdEqualTo(accountId)
            .cardIdEqualTo(card.id)
            .confirmedEqualTo(true)
            .dateBetween(
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
              DateTime.now(),
            )
            .findAll();
      } else {
        cardBills = await isar.cardBills
            .filter()
            .accountIdEqualTo(accountId)
            .cardIdEqualTo(card.id)
            .confirmedEqualTo(true)
            .findAll();
      }
      if (cardBills.isNotEmpty) {
        var installmentValue = 0.0;
        for (final cardBill in cardBills) {
          for (final id in cardBill.installmentIdList) {
            final installment = await isar.exchanges.get(id);
            if (installment != null) {
              installmentValue -= installment.value;
            }
          }
        }
        value += installmentValue;
      }
    }
    return value;
  }
}

Future<List<Exchange>> getCardBillInstallments(
  Isar isar,
  int cardBillId,
) async {
  final cardBill = await isar.cardBills.get(cardBillId);
  final installments = <Exchange>[];

  if (cardBill != null) {
    for (final installmentId in cardBill.installmentIdList) {
      final installment = await isar.exchanges.get(installmentId);
      if (installment != null) {
        installments.add(installment);
      }
    }
  }
  return installments;
}

Future<void> processInstallments(Isar isar, Exchange exchange) async {
  final card = (await fhelper.getCardFromId(isar, exchange.cardId))!;
  var start = 0;

  // Check if exchange should be processed on the same month
  if (exchange.date.day > card.statementClosure ||
      card.paymentDue < card.statementClosure) {
    start = 1;
  }

  await isar.writeTxn(() async {
    // loop between the installments required
    for (var i = start; i < exchange.installments! + start; i++) {
      final billMonth = exchange.date.month + i;
      final cardBill = await _getCardBill(
        isar,
        DateTime(exchange.date.year, billMonth),
        exchange.cardId!,
      );
      final installment = Exchange(
        accountId: exchange.accountId,
        cardId: exchange.cardId,
        description: start == 1
            ? '$i/${exchange.installments!}#/spt#/${exchange.description}'
            : '${i + 1}/${exchange.installments!}#/spt#/${exchange.description}',
        date: exchange.date,
        eType: EType.installment,
        typeId: exchange.typeId,
        value: exchange.installments! == 1
            ? exchange.value
            : exchange.installmentValue!,
        installments: exchange.id,
      );
      final installmentId = await isar.exchanges.put(installment);
      // check for a CardBill
      if (cardBill != null) {
        if (cardBill.confirmed) {
          start++;
          continue;
        }
        // adds the installment to existing CardBill
        final bill = cardBill.copyWith(
          installmentIdList: [...cardBill.installmentIdList, installmentId],
        );
        await isar.cardBills.put(bill);
      } else {
        // add a new CardBill if there is none
        final paymentDueDate = card.paymentDue > _daysOfMonth(billMonth)
            ? _daysOfMonth(billMonth)
            : card.paymentDue;
        final billDate =
            DateTime(exchange.date.year, billMonth, paymentDueDate);
        final bill = CardBill(
          cardId: exchange.cardId!,
          date: billDate,
          installmentIdList: [installmentId],
        );
        await isar.cardBills.put(bill);
      }
    }
  });
}
