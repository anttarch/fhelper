import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:isar/isar.dart';

enum BillPeriod { past, latest, next }

Future<List<CardBill>> getCardBillsFromCard(
  Isar isar,
  int cardId,
  BillPeriod period, {
  bool findOne = false,
}) async {
  var list = <CardBill>[];

  final start = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  final end = start
      .copyWith(month: start.month + 1)
      .subtract(const Duration(microseconds: 1));

  switch (period) {
    case BillPeriod.past:
      list = await isar.cardBills
          .filter()
          .cardIdEqualTo(cardId)
          .dateLessThan(start)
          .findAll();
    case BillPeriod.latest:
      list = await isar.cardBills.filter().cardIdEqualTo(cardId).findAll();
    case BillPeriod.next:
      // Only implemented for upcoming bills (for now)
      if (findOne) {
        final bill = await isar.cardBills
            .filter()
            .cardIdEqualTo(cardId)
            .dateGreaterThan(end)
            .sortByDate()
            .findFirst();
        if (bill != null) {
          list.add(bill);
        }
      } else {
        list = await isar.cardBills
            .filter()
            .cardIdEqualTo(cardId)
            .dateGreaterThan(end)
            .findAll();
      }
  }
  return list;
}
