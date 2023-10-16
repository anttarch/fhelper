import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

extension IntFunctions on int {
  bool between(int first, int last) {
    return this >= first && this <= last;
  }
}

Future<Exchange?> getLatest(
  Isar isar, {
  required BuildContext context,
  int? attributeId,
  AttributeType? attributeType,
}) async {
  assert(
    attributeId != null ? attributeType != null : attributeType == null,
    attributeId != null
        ? 'Attribute type is required'
        : 'Cannot receive an attribute type',
  );
  Exchange? latestExchange;
  CardBill? latestPaidCardBill;

  if (attributeId != null) {
    if (attributeType == AttributeType.account) {
      // gets the latest exchange linked to the given account
      latestExchange = await isar.exchanges
          .filter()
          .accountIdEqualTo(attributeId)
          .or()
          .accountIdEndEqualTo(attributeId)
          .not()
          .eTypeEqualTo(EType.installment)
          .sortByDateDesc()
          .findFirst();

      // gets the latest confirmed cardbill linked to the given account
      final cardBills = await isar.cardBills
          .filter()
          .accountIdEqualTo(attributeId)
          .confirmedEqualTo(true)
          .findAll();
      if (cardBills.isNotEmpty) {
        cardBills.sort((a, b) => b.date.compareTo(a.date));
        latestPaidCardBill = cardBills.first;
      }
    } else {
      // gets the latest exchange linked to type
      // cardbill is not linked to any type
      latestExchange = await isar.exchanges
          .filter()
          .typeIdEqualTo(attributeId)
          .not()
          .eTypeEqualTo(EType.installment)
          .sortByDateDesc()
          .findFirst();
    }
  } else {
    // gets the latest exchnage/cardbill computed
    latestExchange = await isar.exchanges
        .filter()
        .not()
        .eTypeEqualTo(EType.installment)
        .sortByDateDesc()
        .findFirst();
    latestPaidCardBill = await isar.cardBills
        .filter()
        .confirmedEqualTo(true)
        .sortByDateDesc()
        .findFirst();
  }

  // process based on the latest exchange/cardbill
  switch ((latestExchange, latestPaidCardBill)) {
    // returns latest exchange if there is no cardbill
    case (final Exchange? a, final CardBill? b) when a != null && b == null:
      return latestExchange;

    cardBill:
    // returns the latest cardbill if there is no exchange
    case (final Exchange? a, final CardBill? b) when a == null && b != null:
      fhelper.Card? card;
      var value = 0.0;

      // gets the total bill value
      for (final id in latestPaidCardBill!.installmentIdList) {
        final installment = await isar.exchanges.get(id);
        if (installment != null) {
          value -= installment.value;
        }
      }
      card = await fhelper.getCardFromId(isar, latestPaidCardBill.cardId);
      // returns an exchange with the cardbill values
      if (context.mounted) {
        return Exchange(
          id: -1,
          accountId: latestPaidCardBill.accountId,
          description: AppLocalizations.of(context)!.cardBill(card!.name),
          date: latestPaidCardBill.date,
          eType: EType.expense,
          typeId: latestPaidCardBill.id,
          value: value,
        );
      }
      return Exchange(
        id: -1,
        accountId: latestPaidCardBill.accountId,
        description: card!.name,
        date: latestPaidCardBill.date,
        eType: EType.expense,
        typeId: latestPaidCardBill.id,
        value: value,
      );
    // returns a cardbill or exchange depending on which is newer
    case (final Exchange? a, final CardBill? b)
        when a != null && b != null && a.date.isBefore(b.date):
      if (b.date.isBefore(DateTime.now())) {
        // go to cardbill processing
        continue cardBill;
      }
      return a;
    // no cardbill or exchange
    default:
      return null;
  }
}
