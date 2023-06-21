import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/logic/l10n_attributes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:isar/isar.dart';

ShapeBorder? getShapeBorder(int index, int finalIndex) {
  if (finalIndex == 0) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
  } else if (index == finalIndex) {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
    );
  }
  switch (index) {
    case 0:
      return const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      );
    default:
      return null;
  }
}

Future<String> parseTransferName(BuildContext context, Exchange transfer) async {
  final String deleted = AppLocalizations.of(context)!.deleted;
  String from = (await getAttributeFromId(Isar.getInstance()!, transfer.accountId))?.name ?? deleted;
  String to = (await getAttributeFromId(Isar.getInstance()!, transfer.accountIdEnd!))?.name ?? deleted;

  if (transfer.accountId >= 0 && transfer.accountId <= 23 && context.mounted && transfer.description.split('#/spt#/')[0] == '#/str#/') {
    from = translatedDefaultAttribute(context, transfer.accountId)!;
  }
  if (transfer.accountIdEnd! >= 0 && transfer.accountIdEnd! <= 23 && context.mounted && transfer.description.split('#/spt#/')[1] == '#/str#/') {
    to = translatedDefaultAttribute(context, transfer.accountIdEnd!)!;
  }
  if (context.mounted) {
    return AppLocalizations.of(context)!.transferDescription(from, to);
  }
  return '';
}
