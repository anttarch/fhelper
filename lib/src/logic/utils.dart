import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:isar/isar.dart';

Future<Exchange?> getLatest(Isar isar, {int? attributeId, AttributeType? attributeType}) async {
  assert(attributeId != null ? attributeType != null : attributeType == null);
  Exchange? latestExchange;
  CardBill? latestPaidCardBill;

  if (attributeId != null) {
    switch (attributeType) {
      case AttributeType.account:
        latestExchange = await Isar.getInstance()!
            .exchanges
            .where()
            .filter()
            .accountIdEqualTo(attributeId)
            .or()
            .accountIdEndEqualTo(attributeId)
            .not()
            .eTypeEqualTo(EType.installment)
            .sortByDateDesc()
            .findFirst();
        final List<CardBill> cardBills = [];
        final cardsIds = await isar.cards.where().filter().accountIdEqualTo(attributeId).idProperty().findAll();
        for (final id in cardsIds) {
          final cardBill = await isar.cardBills.filter().cardIdEqualTo(id).confirmedEqualTo(true).findAll();
          cardBills.addAll(cardBill);
        }
        if (cardBills.isNotEmpty) {
          cardBills.sort((a, b) => b.date.compareTo(a.date));
          latestPaidCardBill = cardBills.first;
        }
      default:
        latestExchange =
            await Isar.getInstance()!.exchanges.where().filter().typeIdEqualTo(attributeId).not().eTypeEqualTo(EType.installment).sortByDateDesc().findFirst();
    }
  } else {
    latestExchange = await Isar.getInstance()!.exchanges.where().filter().not().eTypeEqualTo(EType.installment).sortByDateDesc().findFirst();
    latestPaidCardBill = await Isar.getInstance()!.cardBills.where().filter().confirmedEqualTo(true).sortByDateDesc().findFirst();
  }

  if (latestPaidCardBill == null && latestExchange == null) {
    return null;
  } else if (latestPaidCardBill == null && latestExchange != null) {
    return latestExchange;
  } else if (latestExchange!.date.isBefore(latestPaidCardBill!.date)) {
    if (latestPaidCardBill.date.isBefore(DateTime.now())) {
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
  return latestExchange;
}
