import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'card_bill.g.dart';

@Collection()
class CardBill {
  CardBill({
    this.id = Isar.autoIncrement,
    required this.cardId,
    this.confirmed = false,
    this.minimal,
    required this.date,
    required this.installmentIdList,
  });

  final Id id; // CardBill id
  final int cardId; // related card id
  final bool confirmed; // if bill is paid/confirmed
  final double? minimal; // minimal paid value
  final DateTime date; // CardBill date
  final List<int> installmentIdList; // CardBill installments

  @override
  String toString() => 'CardBill(id: $id, cardId: $cardId, confirmed: $confirmed, minimal: $minimal, date: $date, installmentIdList: $installmentIdList)';

  CardBill copyWith({
    Id? id,
    int? cardId,
    bool? confirmed,
    double? minimal,
    DateTime? date,
    List<int>? installmentIdList,
  }) {
    return CardBill(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      confirmed: confirmed ?? this.confirmed,
      minimal: minimal ?? this.minimal,
      date: date ?? this.date,
      installmentIdList: installmentIdList ?? this.installmentIdList,
    );
  }
}

int _daysOfMonth(int month) {
  final DateTime startMonth = DateTime(DateTime.now().year, month);
  final DateTime endMonth = DateTime(DateTime.now().year, month + 1);
  return endMonth.difference(startMonth).inDays;
}

Future<CardBill?> getCardBillFromId(Isar isar, int id) async {
  final CardBill? cardBill = await isar.cardBills.get(id);
  return cardBill;
}

Future<CardBill?> _getCardBill(Isar isar, DateTime date, int cardId) async {
  // allows for dates with days, ect.
  final DateTime startDate = DateTime(date.year, date.month);
  final DateTime lastDate = DateTime(date.year, date.month + 1);
  final CardBill? cardBill = await isar.cardBills.filter().cardIdEqualTo(cardId).and().dateGreaterThan(startDate).and().dateLessThan(lastDate).findFirst();
  return cardBill;
}

Future<Map<String, List<double>>> getPendingCardBills(
  Isar isar,
  BuildContext context, {
  int time = 0,
}) async {
  final int weekday = getWeekday(context);
  final DateTime now = DateTime.now();

  final List<CardBill?> today =
      await isar.cardBills.where().filter().dateBetween(DateTime(now.year, now.month, now.day), now).and().confirmedEqualTo(false).sortByDateDesc().findAll();

  final List<CardBill?> week = await isar.cardBills
      .where()
      .filter()
      .dateBetween(
        DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1)),
        now,
      )
      .and()
      .confirmedEqualTo(false)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> month = await isar.cardBills
      .where()
      .filter()
      .dateBetween(
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1),
      )
      .and()
      .confirmedEqualTo(false)
      .sortByDateDesc()
      .findAll();

  final Map<int, List<CardBill?>> timeTable = {
    0: today,
    1: week,
    2: month,
  };

  final Map<String, List<double>> nameValue = {};

  if (timeTable[time]!.isNotEmpty) {
    for (final bill in timeTable[time]!) {
      double value = 0;
      final fhelper.Card? card = await fhelper.getCardFromId(isar, bill!.cardId);
      for (final id in bill.installmentIdList) {
        final Exchange? installment = await isar.exchanges.get(id);
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
  final int weekday = getWeekday(context);
  final DateTime now = DateTime.now();

  final List<CardBill?> today =
      await isar.cardBills.where().filter().dateBetween(DateTime(now.year, now.month, now.day), now).and().confirmedEqualTo(true).sortByDateDesc().findAll();

  final List<CardBill?> week = await isar.cardBills
      .where()
      .filter()
      .dateBetween(
        DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1)),
        now,
      )
      .and()
      .confirmedEqualTo(true)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> month =
      await isar.cardBills.where().filter().dateBetween(DateTime(now.year, now.month), now).and().confirmedEqualTo(true).sortByDateDesc().findAll();

  final Map<int, List<CardBill?>> timeTable = {
    0: today,
    1: week,
    2: month,
  };

  final List<CardBill?> cardBill = timeTable[time]!;
  fhelper.Card? card;
  final List<Exchange> cardBillExchange = [];

  if (cardBill.isNotEmpty) {
    for (final bill in cardBill) {
      double value = 0;
      for (final id in bill!.installmentIdList) {
        final Exchange? installment = await isar.exchanges.get(id);
        if (installment != null) {
          value -= installment.value;
        }
      }
      card = await fhelper.getCardFromId(isar, bill.cardId);
      cardBillExchange.add(
        Exchange(
          id: -1,
          accountId: card!.accountId,
          description: "${card.name}'s bill",
          date: bill.date,
          eType: EType.expense,
          typeId: bill.id,
          value: value,
        ),
      );
    }
  }

  return cardBillExchange;
}

/// `time` map
/// 0 -> today
/// 1 -> all
Future<double> getCardBillSumByAccount(Isar isar, int accountId, {int time = 0}) async {
  double value = 0;

  if (accountId == -1) {
    return value;
  } else {
    final List<fhelper.Card> cards = await isar.cards.filter().accountIdEqualTo(accountId).findAll();
    for (final card in cards) {
      List<CardBill> cardBills = [];
      if (time == 0) {
        cardBills = await isar.cardBills
            .filter()
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
        cardBills = await isar.cardBills.filter().cardIdEqualTo(card.id).confirmedEqualTo(true).findAll();
      }
      if (cardBills.isNotEmpty) {
        double installmentValue = 0;
        for (final cardBill in cardBills) {
          for (final id in cardBill.installmentIdList) {
            final Exchange? installment = await isar.exchanges.get(id);
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

Future<List<Exchange>> getCardBillInstallments(Isar isar, int cardBillId) async {
  final CardBill? cardBill = await isar.cardBills.get(cardBillId);
  final List<Exchange> installments = [];

  if (cardBill != null) {
    for (final installmentId in cardBill.installmentIdList) {
      final Exchange? installment = await isar.exchanges.get(installmentId);
      if (installment != null) {
        installments.add(installment);
      }
    }
  }
  return installments;
}

Future<void> processInstallments(Isar isar, Exchange exchange) async {
  final fhelper.Card card = (await fhelper.getCardFromId(isar, exchange.cardId))!;
  int start = 0;

  // Check if exchange should be processed on the same month
  if (exchange.date.day > card.statementClosure || card.paymentDue < card.statementClosure) {
    start = 1;
  }

  await isar.writeTxn(() async {
    // loop between the installments required
    for (int i = start; i < exchange.installments! + start; i++) {
      final int billMonth = exchange.date.month + i;
      final CardBill? cardBill = await _getCardBill(isar, DateTime(exchange.date.year, billMonth), exchange.cardId!);
      final Exchange installment = Exchange(
        accountId: exchange.accountId,
        cardId: exchange.cardId,
        description:
            start == 1 ? '$i/${exchange.installments!}#/spt#/${exchange.description}' : '${i + 1}/${exchange.installments!}#/spt#/${exchange.description}',
        date: exchange.date,
        eType: EType.installment,
        typeId: exchange.typeId,
        value: exchange.installments! == 1 ? exchange.value : exchange.installmentValue!,
        installments: exchange.id,
      );
      final installmentId = await isar.exchanges.put(installment);
      // check for a CardBill
      if (cardBill != null) {
        // adds the installment to existing CardBill
        final CardBill bill = cardBill.copyWith(installmentIdList: [...cardBill.installmentIdList, installmentId]);
        await isar.cardBills.put(bill);
      } else {
        // add a new CardBill if there is none
        final int paymentDueDate = card.paymentDue > _daysOfMonth(billMonth) ? _daysOfMonth(billMonth) : card.paymentDue;
        final DateTime billDate = DateTime(exchange.date.year, billMonth, paymentDueDate);
        final CardBill bill = CardBill(cardId: exchange.cardId!, date: billDate, installmentIdList: [installmentId]);
        await isar.cardBills.put(bill);
      }
    }
  });
}
