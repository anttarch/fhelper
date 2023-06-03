import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:isar/isar.dart';

enum BillPeriod { past, latest, next }

Future<List<CardBill>> getCardBillsFromCard(Isar isar, int cardId, BillPeriod period, {bool findOne = false}) async {
  List<CardBill> list = [];
  final nowMonthStart = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  final nowMonthEnd = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
  ).subtract(const Duration(microseconds: 1));
  switch (period) {
    case BillPeriod.past:
      list = await isar.cardBills.filter().cardIdEqualTo(cardId).dateLessThan(nowMonthStart).findAll();
    case BillPeriod.next:
      // Only implemented for upcoming bills (for now)
      if (findOne) {
        final CardBill? bill = await isar.cardBills.filter().cardIdEqualTo(cardId).dateGreaterThan(nowMonthEnd).sortByDate().findFirst();
        if (bill != null) {
          list.add(bill);
        }
      } else {
        list = await isar.cardBills.filter().cardIdEqualTo(cardId).dateGreaterThan(nowMonthEnd).findAll();
      }
    default:
      list = await isar.cardBills.filter().cardIdEqualTo(cardId).findAll();
  }
  return list;
}
