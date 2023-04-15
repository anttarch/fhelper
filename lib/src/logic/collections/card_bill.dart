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

  final List<CardBill?> today = await isar.cardBills
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
      .confirmedEqualTo(false)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> week = await isar.cardBills
      .where()
      .filter()
      .dateBetween(
        DateTime.now().subtract(Duration(days: weekday)),
        DateTime.now(),
      )
      .and()
      .confirmedEqualTo(false)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> month = await isar.cardBills
      .where()
      .filter()
      .dateBetween(
        DateTime(DateTime.now().year, DateTime.now().month),
        DateTime.now(),
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
          value -= installment.value;
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

  final List<CardBill?> today = await isar.cardBills
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
      .confirmedEqualTo(true)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> week = await isar.cardBills
      .where()
      .filter()
      .dateBetween(
        DateTime.now().subtract(Duration(days: weekday)),
        DateTime.now(),
      )
      .and()
      .confirmedEqualTo(true)
      .sortByDateDesc()
      .findAll();

  final List<CardBill?> month = await isar.cardBills
      .where()
      .filter()
      .dateBetween(
        DateTime(DateTime.now().year, DateTime.now().month),
        DateTime.now(),
      )
      .and()
      .confirmedEqualTo(true)
      .sortByDateDesc()
      .findAll();

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

Future<void> processInstallments(Isar isar, Exchange exchange) async {
  int installments = exchange.installments!;
  final fhelper.Card card = (await fhelper.getCardFromId(isar, exchange.cardId))!;
  int start = 0;

  // Check if exchange should be processed on the same month
  if (exchange.date.day > card.statementClosure || card.paymentDue < card.statementClosure) {
    start = 1;
    installments += 1;
  }

  await isar.writeTxn(() async {
    // loop between the installments required
    for (int i = start; i < installments; i++) {
      final int billMonth = exchange.date.month + i;
      final CardBill? cardBill = await _getCardBill(isar, DateTime(exchange.date.year, billMonth), exchange.cardId!);
      final Exchange installment = Exchange(
        accountId: exchange.accountId,
        cardId: exchange.cardId,
        description: start == 1 ? '$i - ${exchange.description}' : '${i + 1} - ${exchange.description}',
        date: exchange.date,
        eType: EType.installment,
        typeId: exchange.typeId,
        value: installments == 1 ? exchange.value : exchange.installmentValue!,
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
