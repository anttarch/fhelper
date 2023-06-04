import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Default attributes are located at assets/attributes.json
///
/// Range from id=0 to id=20
///
/// - Accounts (type 0) -> from 0 to 1
/// - Income Types (type 1) -> from 2 to 6
/// - Expense Types (type 2) -> from 7 to 20
String? translatedDefaultAttribute(BuildContext context, int defaultAttributeid) => switch (defaultAttributeid) {
      // Accounts
      0 => AppLocalizations.of(context)!.mainBankAccountAccount,
      1 => AppLocalizations.of(context)!.walletAccount,

      // Income Types
      2 => AppLocalizations.of(context)!.benefitsIncomeType,
      3 => AppLocalizations.of(context)!.giftsIncomeType,
      4 => AppLocalizations.of(context)!.loansIncomeType,
      5 => AppLocalizations.of(context)!.salaryIncomeType,
      6 => AppLocalizations.of(context)!.othersIncomeType,

      // Expense Types

      // FOOD
      7 => AppLocalizations.of(context)!.foodExpenseType,
      8 => AppLocalizations.of(context)!.marketFOOD,
      9 => AppLocalizations.of(context)!.streetMarketFOOD,
      10 => AppLocalizations.of(context)!.bakeryFOOD,
      11 => AppLocalizations.of(context)!.restaurantFOOD,
      12 => AppLocalizations.of(context)!.othersExpenseType,

      // HOME
      13 => AppLocalizations.of(context)!.homeExpenseType,
      14 => AppLocalizations.of(context)!.housePaymentHOME,
      15 => AppLocalizations.of(context)!.cleaningHOME,
      16 => AppLocalizations.of(context)!.waterBillHOME,
      17 => AppLocalizations.of(context)!.electricityBillHOME,
      18 => AppLocalizations.of(context)!.propertyTaxHOME,
      19 => AppLocalizations.of(context)!.internetTVHOME,
      20 => AppLocalizations.of(context)!.othersExpenseType,
      // 8 => AppLocalizations.of(context)!.billsExpenseType,
      // 9 => AppLocalizations.of(context)!.healthExpenseType,
      // 10 => AppLocalizations.of(context)!.homeExpenseType,
      // 11 => AppLocalizations.of(context)!.personalExpenseType,
      // 12 => AppLocalizations.of(context)!.recreationExpenseType,
      // 13 => AppLocalizations.of(context)!.transportsExpenseType,
      // 14 => AppLocalizations.of(context)!.othersExpenseType,
      _ => null,
    };
