import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:isar/isar.dart';

Future<Exchange?> getLatest(Isar isar) async {
  final latestExchange = await Isar.getInstance()!.exchanges.where().sortByDateDesc().findFirst();
  final latestPaidCardBill = await Isar.getInstance()!.cardBills.where().filter().confirmedEqualTo(true).sortByDateDesc().findFirst();

  if (latestPaidCardBill == null && latestExchange == null) {
    return null;
  } else if (latestPaidCardBill == null && latestExchange != null) {
    return latestExchange;
  } else if (latestExchange!.date.isBefore(latestPaidCardBill!.date)) {
    fhelper.Card? card;
    double value = 0;
    for (final id in latestPaidCardBill.installmentIdList) {
      final Exchange? installment = await isar.exchanges.get(id);
      if (installment != null) {
        value -= installment.value;
      }
    }
    card = await fhelper.getCardFromId(isar, latestPaidCardBill.cardId);
    return Exchange(
      id: -1,
      accountId: card!.accountId,
      description: "${card.name}'s bill",
      date: latestPaidCardBill.date,
      eType: EType.expense,
      typeId: latestPaidCardBill.id,
      value: value,
    );
  }
  return latestExchange;
}
